import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';

/// Un enregistrement capturé par [InMemoryLoggerService].
class LogRecord {
  final LogLevel level;
  final String message;
  final Map<String, Object?> attributes;
  final Object? error;

  const LogRecord({
    required this.level,
    required this.message,
    required this.attributes,
    this.error,
  });
}

/// [LoggerService] qui conserve les enregistrements en mémoire, pour que les
/// tests puissent affirmer qu'un événement a bien été journalisé sans polluer
/// la sortie de la suite.
class InMemoryLoggerService implements LoggerService {
  final List<LogRecord> records = [];

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    records.add(
      LogRecord(
        level: level,
        message: message,
        attributes: attributes,
        error: error,
      ),
    );
  }

  @override
  Future<void> flush() async {}

  /// Vrai si un enregistrement porte exactement [message].
  bool has(String message) => records.any((r) => r.message == message);
}
