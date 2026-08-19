import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:bible/infrastructure/auth/dio.auth.repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_dio.dart';

void main() {
  group('DioAuthRepository', () {
    test('échange les identifiants contre une session', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioAuthRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, {
            'token': 'token-abc',
            'user': {'id': 7, 'name': 'Jean', 'email': 'jean@example.com'},
          }),
        ),
        deviceName: 'iPhone de Jean',
      );

      final session = await repository.signIn(
        email: 'jean@example.com',
        password: 'secret',
      );

      expect(session.token, 'token-abc');
      expect(session.user.id, 7);
      expect(session.user.email, 'jean@example.com');
      expect(recorded.single.method, 'POST');
      expect(recorded.single.path, '/api/auth/login');
      expect(
        recorded.single.data,
        containsPair('device_name', 'iPhone de Jean'),
      );
    });

    test('traduit invalid_credentials en message affichable', () async {
      final repository = DioAuthRepository(
        stubDio(
          handler: (_) => const StubResponse(401, {
            'error': 'Identifiants incorrects.',
            'code': 'invalid_credentials',
          }),
        ),
      );

      expect(
        () => repository.signIn(email: 'jean@example.com', password: 'faux'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Adresse e-mail ou mot de passe incorrect.',
          ),
        ),
      );
    });

    test('remonte les erreurs de validation champ par champ', () async {
      final repository = DioAuthRepository(
        stubDio(
          handler: (_) => const StubResponse(422, {
            'error': 'The email has already been taken.',
            'code': 'invalid_request',
            'errors': {
              'email': ['Cette adresse est déjà utilisée.'],
            },
          }),
        ),
      );

      expect(
        () => repository.signUp(
          name: 'Jean',
          email: 'jean@example.com',
          password: 'secret',
          passwordConfirmation: 'secret',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.fieldErrors['email'],
            'erreur du champ email',
            'Cette adresse est déjà utilisée.',
          ),
        ),
      );
    });

    test('distingue un serveur injoignable d\'une erreur applicative', () async {
      final repository = DioAuthRepository(
        stubDio(handler: (_) => throw StateError('réseau coupé')),
      );

      expect(
        () => repository.signIn(email: 'jean@example.com', password: 'secret'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Connexion au serveur impossible'),
          ),
        ),
      );
    });
  });
}
