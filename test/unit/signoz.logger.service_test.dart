import 'dart:convert';

import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/infrastructure/logger/signoz.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_dio.dart';

void main() {
  group('SignozLoggerService.normalizeEndpoint', () {
    test('complète une origine nue en chemin OTLP des logs', () {
      expect(
        SignozLoggerService.normalizeEndpoint('https://signoz.test:4318'),
        'https://signoz.test:4318/v1/logs',
      );
    });

    test('tolère une barre oblique finale', () {
      expect(
        SignozLoggerService.normalizeEndpoint('https://signoz.test:4318/'),
        'https://signoz.test:4318/v1/logs',
      );
    });

    test('laisse intacte une URL déjà complète', () {
      expect(
        SignozLoggerService.normalizeEndpoint(
          'https://signoz.test:4318/v1/logs',
        ),
        'https://signoz.test:4318/v1/logs',
      );
    });
  });

  group('SignozLoggerService', () {
    test('expédie une charge OTLP portant ressource et enregistrement', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded);

      await logger.log(
        LogLevel.error,
        'reading.load_failed',
        attributes: {'session.id': 'abc', 'user.id': 7, 'http.status': 500},
      );
      await logger.flush();

      final payload = _payloadOf(recorded.single);
      final resource =
          payload['resourceLogs'][0]['resource']['attributes'] as List;
      expect(
        _attributesOf(resource),
        containsPair('service.name', 'bible'),
      );

      final record =
          payload['resourceLogs'][0]['scopeLogs'][0]['logRecords'][0]
              as Map<String, dynamic>;
      expect(record['severityNumber'], 17);
      expect(record['severityText'], 'ERROR');
      expect(record['body']['stringValue'], 'reading.load_failed');
      expect(
        _attributesOf(record['attributes'] as List),
        allOf(
          containsPair('session.id', 'abc'),
          // Un entier OTLP voyage en chaîne : c'est le seul encodage que tous
          // les décodeurs JSON restituent sans perte sur 64 bits.
          containsPair('user.id', '7'),
          containsPair('http.status', '500'),
        ),
      );
    });

    test('traduit erreur et pile en attributs `exception.*`', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded);

      await logger.log(
        LogLevel.error,
        'dart.uncaught',
        error: const FormatException('corps illisible'),
        stack: StackTrace.fromString('#0 quelque part'),
      );
      await logger.flush();

      final record =
          _payloadOf(
                recorded.single,
              )['resourceLogs'][0]['scopeLogs'][0]['logRecords'][0]
              as Map<String, dynamic>;
      final attributes = _attributesOf(record['attributes'] as List);
      expect(attributes['exception.type'], 'FormatException');
      expect(attributes['exception.message'], contains('corps illisible'));
      expect(attributes['exception.stacktrace'], contains('quelque part'));
    });

    test('n\'expédie rien tant que le lot n\'est pas plein', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded, maxBatchSize: 3);

      await logger.log(LogLevel.info, 'app.started');
      await logger.log(LogLevel.info, 'ui.screen');

      expect(recorded, isEmpty);
    });

    test('expédie dès que le lot est plein, en un seul envoi', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded, maxBatchSize: 3);

      for (var i = 0; i < 3; i++) {
        await logger.log(LogLevel.info, 'ui.screen');
      }
      // L'envoi déclenché par le remplissage n'est pas attendu par `log` : on
      // laisse la boucle d'événements le mener à terme.
      await _until(() => recorded.isNotEmpty);

      expect(recorded, hasLength(1));
      expect(
        _payloadOf(recorded.single)['resourceLogs'][0]['scopeLogs'][0]['logRecords'],
        hasLength(3),
      );
    });

    test('sacrifie les plus anciens quand la file déborde', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded, maxBatchSize: 100, maxQueueSize: 2);

      await logger.log(LogLevel.info, 'premier');
      await logger.log(LogLevel.info, 'deuxième');
      await logger.log(LogLevel.info, 'troisième');
      await logger.flush();

      final records =
          _payloadOf(
                recorded.single,
              )['resourceLogs'][0]['scopeLogs'][0]['logRecords']
              as List;
      expect(
        records.map((r) => (r as Map)['body']['stringValue']),
        ['deuxième', 'troisième'],
      );
    });

    test('ne lève pas quand l\'envoi échoue', () async {
      final logger = SignozLoggerService(
        endpoint: 'https://signoz.test:4318',
        dio: stubDio(handler: (_) => const StubResponse(503)),
      );
      addTearDown(logger.dispose);

      await logger.log(LogLevel.error, 'flutter.error');

      await expectLater(logger.flush(), completes);
    });

    test('vide le tampon : un second flush n\'expédie rien', () async {
      final recorded = <RecordedRequest>[];
      final logger = _loggerWith(recorded);

      await logger.log(LogLevel.info, 'app.started');
      await logger.flush();
      await logger.flush();

      expect(recorded, hasLength(1));
    });
  });
}

SignozLoggerService _loggerWith(
  List<RecordedRequest> recorded, {
  int maxBatchSize = 50,
  int maxQueueSize = 500,
}) {
  final logger = SignozLoggerService(
    endpoint: 'https://signoz.test:4318',
    ingestionKey: 'jeton-test',
    resourceAttributes: const {'service.name': 'bible'},
    maxBatchSize: maxBatchSize,
    maxQueueSize: maxQueueSize,
    dio: stubDio(
      recorded: recorded,
      handler: (_) => const StubResponse(200, {}),
    ),
  );
  addTearDown(logger.dispose);
  return logger;
}

/// Rend la main jusqu'à ce que [condition] soit vraie, ou échoue au bout d'une
/// seconde. L'envoi déclenché par un lot plein part sans être attendu : rien
/// dans l'API publique ne permet de s'y raccrocher.
Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition jamais satisfaite');
}

Map<String, dynamic> _payloadOf(RecordedRequest request) =>
    jsonDecode(request.data! as String) as Map<String, dynamic>;

/// Aplatit un `KeyValue[]` OTLP en table lisible. Les valeurs sont rendues
/// telles qu'encodées — d'où les entiers en chaîne.
Map<String, Object?> _attributesOf(List<dynamic> raw) {
  return {
    for (final entry in raw.cast<Map<String, dynamic>>())
      entry['key'] as String:
          (entry['value'] as Map<String, dynamic>).values.first,
  };
}
