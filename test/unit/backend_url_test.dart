import 'package:bible/core/utils/backend_endpoints.dart';
import 'package:bible/core/utils/backend_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendUrl.normalize', () {
    test('réduit une URL à son origine', () {
      expect(
        BackendUrl.normalize('https://bible.dtfh.fr/dashboard?a=1#b'),
        'https://bible.dtfh.fr',
      );
    });

    test('conserve un port non standard', () {
      expect(
        BackendUrl.normalize('http://localhost:8000/'),
        'http://localhost:8000',
      );
    });

    test('laisse une valeur inanalysable telle quelle', () {
      expect(BackendUrl.normalize('  pas une url '), 'pas une url');
    });
  });

  group('BackendEndpoints.isPublic', () {
    test('connexion et inscription sont publiques', () {
      expect(BackendEndpoints.isPublic(BackendEndpoints.login), isTrue);
      expect(BackendEndpoints.isPublic(BackendEndpoints.register), isTrue);
    });

    test('la déconnexion porte le jeton qu\'elle révoque', () {
      expect(BackendEndpoints.isPublic(BackendEndpoints.logout), isFalse);
    });

    test('les routes de données sont protégées', () {
      expect(BackendEndpoints.isPublic(BackendEndpoints.readingPlan), isFalse);
      expect(BackendEndpoints.isPublic(BackendEndpoints.profile), isFalse);
    });
  });
}
