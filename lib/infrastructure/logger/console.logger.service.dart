import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';
import 'package:flutter/foundation.dart';

/// [LoggerService] qui écrit dans la console via [debugPrint].
///
/// [debugPrint] est choisi plutôt que `dart:developer`'s `log()` : c'est le
/// canal qui remonte réellement dans le terminal de `flutter run` et dans
/// `adb logcat`, là où `developer.log()` n'apparaît que dans DevTools. La
/// limitation de débit qu'applique [debugPrint] évite en prime que logcat
/// perde des lignes sous charge.
///
/// Une ligne par enregistrement : `NIVEAU message clé=valeur …`, suivie de la
/// pile d'appels quand il y en a une. Sans tampon : `flush()` ne fait rien.
class ConsoleLoggerService implements LoggerService {
  /// Marqueur ajouté en tête de ligne. Sert à distinguer, quand ce service est
  /// enveloppé dans un `CompositeLoggerService`, les enregistrements qui
  /// partent *aussi* vers Signoz (`[→signoz]`) : la console devient alors la
  /// lecture fidèle de ce qui est expédié.
  final String? prefix;

  const ConsoleLoggerService({this.prefix});

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    final buffer = StringBuffer();
    if (prefix != null) buffer.write('$prefix ');
    // Le niveau fait partie du texte : [debugPrint] n'a pas de paramètre de
    // sévérité.
    buffer.write('${level.otelSeverityText} ');
    buffer.write(message);
    if (attributes.isNotEmpty) {
      buffer.write(' ');
      buffer.writeAll(
        attributes.entries.map((e) => '${e.key}=${_format(e.value)}'),
        ' ',
      );
    }
    if (error != null) buffer.write(' error=${_format(error)}');
    debugPrint(buffer.toString());
    if (stack != null) debugPrint(stack.toString());
  }

  @override
  Future<void> flush() async {}

  String _format(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      // Guillemets seulement si la valeur contient un espace, pour que la ligne
      // reste facile à filtrer.
      return value.contains(RegExp(r'\s')) ? '"$value"' : value;
    }
    return value.toString();
  }
}
