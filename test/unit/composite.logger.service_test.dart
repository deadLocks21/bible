import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';
import 'package:bible/infrastructure/logger/composite.logger.service.dart';
import 'package:bible/infrastructure/logger/in_memory.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompositeLoggerService', () {
    test('diffuse chaque enregistrement à tous ses enfants', () async {
      final premier = InMemoryLoggerService();
      final second = InMemoryLoggerService();
      final composite = CompositeLoggerService([premier, second]);

      await composite.log(
        LogLevel.warn,
        'http.failed',
        attributes: {'http.status': 500},
      );

      for (final enfant in [premier, second]) {
        expect(enfant.records.single.message, 'http.failed');
        expect(enfant.records.single.level, LogLevel.warn);
        expect(enfant.records.single.attributes['http.status'], 500);
      }
    });

    test('un enfant défaillant ne rend pas les autres muets', () async {
      final sain = InMemoryLoggerService();
      final composite = CompositeLoggerService([_ThrowingLogger(), sain]);

      await composite.log(LogLevel.error, 'flutter.error');

      expect(sain.has('flutter.error'), isTrue);
    });

    test('un enfant défaillant ne fait pas échouer le vidage', () async {
      final composite = CompositeLoggerService([
        _ThrowingLogger(),
        InMemoryLoggerService(),
      ]);

      await expectLater(composite.flush(), completes);
    });
  });
}

/// Adaptateur qui viole le contrat de [LoggerService] en levant : c'est
/// précisément ce contre quoi le composite se protège.
class _ThrowingLogger implements LoggerService {
  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async => throw StateError('adaptateur cassé');

  @override
  Future<void> flush() async => throw StateError('adaptateur cassé');
}
