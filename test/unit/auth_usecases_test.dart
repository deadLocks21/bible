import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/application/usecases/restore_session.usecase.dart';
import 'package:bible/core/application/usecases/sign_out.usecase.dart';
import 'package:bible/core/application/usecases/sign_up.usecase.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/infrastructure/auth/in_memory.auth_token_store.dart';
import 'package:bible/infrastructure/logger/in_memory.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../builders/builders.dart';
import '../functionnals/utils/fake_repositories.dart';

/// Stockage qui échoue systématiquement, pour vérifier que l'application
/// dégrade proprement quand les préférences sont illisibles.
class _BrokenTokenStore implements AuthTokenStore {
  @override
  Future<AuthSession?> read() async => throw StateError('stockage illisible');

  @override
  Future<void> write(AuthSession session) async =>
      throw StateError('stockage illisible');

  @override
  Future<void> clear() async => throw StateError('stockage illisible');
}

void main() {
  late InMemoryLoggerService sink;
  late LoggerApplicationService logger;

  setUp(() {
    sink = InMemoryLoggerService();
    logger = LoggerApplicationService(sink);
  });

  group('SignOutUseCase', () {
    test('efface la session locale même si la révocation échoue', () async {
      final store = InMemoryAuthTokenStore(anAuthSession());
      final auth = _FailingSignOutRepository();

      await SignOutUseCase(auth, store, logger).execute();

      expect(await store.read(), isNull);
      expect(sink.has('auth.sign_out_remote_failed'), isTrue);
      expect(sink.has('auth.signed_out'), isTrue);
    });
  });

  group('RestoreSessionUseCase', () {
    test('renvoie la session persistée', () async {
      final store = InMemoryAuthTokenStore(anAuthSession(token: 'token-42'));

      final session = await RestoreSessionUseCase(store, logger).execute();

      expect(session?.token, 'token-42');
    });

    test('dégrade en « pas de session » si le stockage est illisible', () async {
      final session = await RestoreSessionUseCase(
        _BrokenTokenStore(),
        logger,
      ).execute();

      expect(session, isNull);
      expect(sink.has('auth.restore_failed'), isTrue);
    });
  });

  group('SignUpUseCase', () {
    test('refuse une confirmation divergente sans appeler le serveur', () async {
      final auth = FakeAuthRepository(session: anAuthSession());
      final store = InMemoryAuthTokenStore();

      final result = await SignUpUseCase(auth, store, logger).execute(
        name: 'Jean',
        email: 'jean@example.com',
        password: 'secret',
        passwordConfirmation: 'autre',
      );

      expect(result, isA<SignUpFailure>());
      expect(
        (result as SignUpFailure).fieldErrors,
        containsPair(
          'password_confirmation',
          'Les mots de passe ne correspondent pas.',
        ),
      );
      expect(await store.read(), isNull);
    });
  });

  group('UpdateProfileUseCase', () {
    test('répercute le nouveau nom sur la session stockée', () async {
      final store = InMemoryAuthTokenStore(
        anAuthSession(user: aUser(name: 'Jean')),
      );

      final result = await UpdateProfileUseCase(
        FakeProfileRepository(),
        store,
        logger,
      ).execute(name: 'Marie', email: 'marie@example.com');

      expect(result, isA<ProfileUpdated>());
      final session = await store.read();
      expect(session?.user.name, 'Marie');
      expect(session?.user.email, 'marie@example.com');
      // Le jeton, lui, ne change pas : ce n'est pas une réauthentification.
      expect(session?.token, 'token-1');
    });
  });
}

class _FailingSignOutRepository extends FakeAuthRepository {
  @override
  Future<void> signOut() async => throw StateError('serveur injoignable');
}
