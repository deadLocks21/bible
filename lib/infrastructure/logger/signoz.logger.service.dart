import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';
import 'package:dio/dio.dart';

/// Expédie les enregistrements de log vers une instance Signoz, en OTLP/HTTP.
///
/// Format de transport : la charge utile JSON `ExportLogsServiceRequest`
/// d'OpenTelemetry, postée sur `<origine d'ingestion>/v1/logs`. Signoz accepte
/// nativement l'encodage JSON du protobuf : une charge écrite à la main pèse
/// moins lourd que d'embarquer `opentelemetry` et son exportateur OTLP, dont
/// les portages Dart restent inégaux.
///
/// ## Attributs de ressource
///
/// Chaque lot porte les [resourceAttributes] passés à la construction
/// (`service.name`, `service.version`, `deployment.environment`, `os.type`…).
/// Ils apparaissent en colonnes `resource.*` dans Signoz et sont la bonne
/// maille pour découper un tableau de bord.
///
/// ## Mise en lot
///
/// Les enregistrements s'accumulent en mémoire et partent :
///
/// - dès que [maxBatchSize] est atteint ;
/// - sinon toutes les [flushInterval], par une minuterie périodique ;
/// - sur appel explicite de [flush] (mise en arrière-plan de l'application).
///
/// La file est bornée à [maxQueueSize] pour qu'une panne réseau prolongée ne
/// fasse pas enfler la mémoire — les plus anciens sont sacrifiés d'abord.
///
/// ## Comportement en cas de panne
///
/// Les erreurs réseau sont rattrapées et signalées via `dart:developer` — et
/// non via [LoggerService], qui bouclerait. Le lot perdu n'est pas rejoué :
/// la télémétrie est au mieux-effort, et une file de reprise risquerait
/// d'empiler des doublons à chaque échec passager.
class SignozLoggerService implements LoggerService {
  /// Point d'entrée OTLP HTTP complet, par exemple
  /// `https://signoz.example.org:4318/v1/logs`.
  ///
  /// Une origine seule (`https://signoz.example.org:4318`) est acceptée : le
  /// suffixe `/v1/logs` est ajouté au besoin, pour qu'un secret de CI mal
  /// renseigné n'envoie pas les logs dans le vide.
  final String endpoint;

  /// Jeton d'ingestion, envoyé en en-tête `signoz-access-token`. `null` ou vide
  /// pour une instance auto-hébergée sans authentification.
  final String? ingestionKey;

  /// Attributs de ressource OTLP attachés à chaque lot.
  final Map<String, Object?> resourceAttributes;

  final Dio _dio;
  final Duration flushInterval;
  final int maxBatchSize;
  final int maxQueueSize;

  final List<_PendingRecord> _buffer = [];
  Timer? _timer;
  bool _disposed = false;
  Future<void>? _inflight;

  SignozLoggerService({
    required String endpoint,
    this.ingestionKey,
    this.resourceAttributes = const {},
    this.flushInterval = const Duration(seconds: 10),
    this.maxBatchSize = 50,
    this.maxQueueSize = 500,
    Dio? dio,
  }) : endpoint = normalizeEndpoint(endpoint),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 5),
               sendTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               contentType: Headers.jsonContentType,
               // La réponse d'un collecteur OTLP ne nous apprend rien : on
               // évite de la faire décoder en JSON pour rien.
               responseType: ResponseType.plain,
             ),
           ) {
    _timer = Timer.periodic(flushInterval, (_) => unawaited(flush()));
  }

  /// Complète une URL d'ingestion en chemin OTLP des logs.
  ///
  /// Tolère l'origine nue comme l'URL complète : le `--dart-define` est
  /// renseigné à la main dans les secrets de CI, et une barre oblique finale ou
  /// un `/v1/logs` oublié ne doit pas se solder par des logs silencieusement
  /// perdus.
  static String normalizeEndpoint(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    if (withoutTrailingSlash.endsWith('/v1/logs')) return withoutTrailingSlash;
    return '$withoutTrailingSlash/v1/logs';
  }

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    if (_disposed) return;
    // File pleine : on sacrifie le plus ancien. Ce qui vient de se produire
    // renseigne davantage sur la panne en cours que ce qui date de dix minutes.
    if (_buffer.length >= maxQueueSize) {
      _buffer.removeAt(0);
    }
    _buffer.add(
      _PendingRecord(
        timestampNanos: _nowUnixNano(),
        level: level,
        message: message,
        attributes: attributes,
        error: error,
        stack: stack,
      ),
    );
    if (_buffer.length >= maxBatchSize) {
      unawaited(flush());
    }
  }

  @override
  Future<void> flush() async {
    // Un seul envoi à la fois : deux `flush` concurrents se rejoignent sur le
    // même futur plutôt que de découper le tampon en deux lots.
    final inflight = _inflight;
    if (inflight != null) return inflight;
    if (_buffer.isEmpty) return;
    final batch = List<_PendingRecord>.from(_buffer);
    _buffer.clear();
    final future = _ship(batch);
    _inflight = future;
    try {
      await future;
    } finally {
      _inflight = null;
    }
  }

  Future<void> _ship(List<_PendingRecord> batch) async {
    try {
      await _dio.post<dynamic>(
        endpoint,
        data: jsonEncode(_buildPayload(batch)),
        options: Options(
          headers: {
            if (ingestionKey != null && ingestionKey!.isNotEmpty)
              'signoz-access-token': ingestionKey,
          },
        ),
      );
    } catch (e, stack) {
      // Ne jamais lever : la télémétrie ne fait pas tomber l'application. On
      // remonte dans la console de développement — surtout pas dans
      // [LoggerService], qui rappellerait ce même code.
      developer.log(
        'signoz: envoi de ${batch.length} enregistrement(s) impossible, lot abandonné',
        name: 'bible.logger',
        level: 900,
        error: e,
        stackTrace: stack,
      );
    }
  }

  Map<String, dynamic> _buildPayload(List<_PendingRecord> batch) {
    return {
      'resourceLogs': [
        {
          'resource': {'attributes': _otlpAttributes(resourceAttributes)},
          'scopeLogs': [
            {
              'scope': {'name': 'bible.app'},
              'logRecords': batch.map(_otlpRecord).toList(growable: false),
            },
          ],
        },
      ],
    };
  }

  Map<String, dynamic> _otlpRecord(_PendingRecord record) {
    final attributes = <String, Object?>{...record.attributes};
    if (record.error != null) {
      // Noms normalisés OTLP : Signoz sait les regrouper en « exceptions ».
      attributes['exception.type'] = record.error.runtimeType.toString();
      attributes['exception.message'] = record.error.toString();
    }
    if (record.stack != null) {
      attributes['exception.stacktrace'] = record.stack.toString();
    }
    return {
      'timeUnixNano': record.timestampNanos.toString(),
      'severityNumber': record.level.otelSeverityNumber,
      'severityText': record.level.otelSeverityText,
      'body': {'stringValue': record.message},
      'attributes': _otlpAttributes(attributes),
    };
  }

  /// Encode une table plate dans la forme `KeyValue[]` attendue par OTLP.
  ///
  /// Un type inconnu est converti par `toString()` plutôt qu'écarté : mieux
  /// vaut une valeur approximative dans Signoz qu'un attribut manquant au
  /// moment où l'on cherche à comprendre une panne.
  List<Map<String, dynamic>> _otlpAttributes(Map<String, Object?> map) {
    final result = <Map<String, dynamic>>[];
    for (final entry in map.entries) {
      final value = entry.value;
      Map<String, dynamic> wrapped;
      if (value == null) {
        // OTLP n'a pas de nul explicite : la chaîne vide garde la clé indexée.
        wrapped = {'stringValue': ''};
      } else if (value is String) {
        wrapped = {'stringValue': value};
      } else if (value is bool) {
        wrapped = {'boolValue': value};
      } else if (value is int) {
        // `intValue` se transporte en chaîne : un entier 64 bits ne survit pas
        // au JSON de tous les décodeurs.
        wrapped = {'intValue': value.toString()};
      } else if (value is double) {
        wrapped = {'doubleValue': value};
      } else {
        wrapped = {'stringValue': value.toString()};
      }
      result.add({'key': entry.key, 'value': wrapped});
    }
    return result;
  }

  int _nowUnixNano() => DateTime.now().microsecondsSinceEpoch * 1000;

  /// Arrête la minuterie et expédie ce qui reste. Appelé à la disposition du
  /// provider et depuis les tests.
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await flush();
    _dio.close(force: true);
  }
}

class _PendingRecord {
  final int timestampNanos;
  final LogLevel level;
  final String message;
  final Map<String, Object?> attributes;
  final Object? error;
  final StackTrace? stack;

  const _PendingRecord({
    required this.timestampNanos,
    required this.level,
    required this.message,
    required this.attributes,
    this.error,
    this.stack,
  });
}
