import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/infrastructure/profile/dio.profile.repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_dio.dart';

void main() {
  group('DioProfileRepository', () {
    test('met à jour nom et e-mail', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioProfileRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, {
            'user': {'id': 3, 'name': 'Marie', 'email': 'marie@example.com'},
          }),
        ),
      );

      final user = await repository.updateProfile(
        name: 'Marie',
        email: 'marie@example.com',
      );

      expect(user.name, 'Marie');
      expect(recorded.single.method, 'PATCH');
      expect(recorded.single.path, '/api/profile');
    });

    test('remonte un mot de passe actuel erroné sur son champ', () async {
      final repository = DioProfileRepository(
        stubDio(
          handler: (_) => const StubResponse(422, {
            'error': 'The password is incorrect.',
            'code': 'invalid_request',
            'errors': {
              'current_password': ['Le mot de passe est incorrect.'],
            },
          }),
        ),
      );

      expect(
        () => repository.updatePassword(
          currentPassword: 'faux',
          password: 'nouveau',
          passwordConfirmation: 'nouveau',
        ),
        throwsA(
          isA<ProfileException>().having(
            (e) => e.fieldErrors['current_password'],
            'erreur du champ current_password',
            'Le mot de passe est incorrect.',
          ),
        ),
      );
    });

    test('supprime le compte en confirmant le mot de passe', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioProfileRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, {'deleted': true}),
        ),
      );

      await repository.deleteAccount(password: 'secret');

      expect(recorded.single.method, 'DELETE');
      expect(recorded.single.data, containsPair('password', 'secret'));
    });
  });
}
