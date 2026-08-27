import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/infrastructure/logger/in_memory.logger.service.dart';
import 'package:bible/infrastructure/logger/logging.provider_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ces erreurs ne traversent ni `FlutterError.onError` ni
/// `PlatformDispatcher.onError` : Riverpod les rattrape pour les ranger dans
/// l'état du provider. L'observateur est le seul à pouvoir les voir.
class _SondeException implements Exception {
  const _SondeException();
  @override
  String toString() => 'SondeException';
}

void main() {
  group('LoggingProviderObserver', () {
    test('journalise l\'échec d\'un provider synchrone', () {
      final logger = InMemoryLoggerService();
      final container = _containerWith(logger);
      final provider = Provider<int>(
        (ref) => throw const _SondeException(),
        name: 'sondeProvider',
      );

      expect(() => container.read(provider), throwsA(anything));

      final record = logger.records.single;
      expect(record.level, LogLevel.error);
      expect(record.message, 'provider.failed');
      expect(record.attributes['provider.name'], 'sondeProvider');
      expect(record.error, isA<_SondeException>());
    });

    test('journalise l\'échec d\'un provider asynchrone', () async {
      final logger = InMemoryLoggerService();
      final container = _containerWith(logger);
      final provider = FutureProvider<int>(
        (ref) async => throw const _SondeException(),
        name: 'sondeAsyncProvider',
      );

      await expectLater(
        container.read(provider.future),
        throwsA(isA<_SondeException>()),
      );

      expect(logger.has('provider.failed'), isTrue);
      expect(
        logger.records.first.attributes['provider.name'],
        'sondeAsyncProvider',
      );
    });

    test('nomme le provider par son type à défaut de nom', () {
      final logger = InMemoryLoggerService();
      final container = _containerWith(logger);
      final provider = Provider<int>((ref) => throw const _SondeException());

      expect(() => container.read(provider), throwsA(anything));

      expect(
        logger.records.single.attributes['provider.name'],
        isA<String>().having((n) => n.isNotEmpty, 'non vide', isTrue),
      );
    });
  });
}

ProviderContainer _containerWith(InMemoryLoggerService logger) {
  final container = ProviderContainer(
    observers: [
      LoggingProviderObserver(() => LoggerApplicationService(logger)),
    ],
    // Riverpod 3 réessaie par défaut un provider en échec jusqu'à dix fois,
    // avec un délai croissant : le test y passerait une demi-minute et
    // compterait onze enregistrements au lieu d'un.
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  return container;
}
