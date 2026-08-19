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

  group('BackendUrl.validate', () {
    test('accepte une origine', () {
      expect(BackendUrl.validate('https://bible.dtfh.fr'), isNull);
    });

    test('refuse une URL sans schéma', () {
      expect(BackendUrl.validate('bible.dtfh.fr'), isNotNull);
    });

    test('refuse une URL comportant un chemin', () {
      expect(
        BackendUrl.validate('https://bible.dtfh.fr/api'),
        contains('sans chemin'),
      );
    });
  });

  group('BackendUrl.join', () {
    test('écrase la barre oblique intermédiaire', () {
      expect(
        BackendUrl.join('https://x.fr/', '/api/me'),
        'https://x.fr/api/me',
      );
      expect(BackendUrl.join('https://x.fr', 'api/me'), 'https://x.fr/api/me');
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
