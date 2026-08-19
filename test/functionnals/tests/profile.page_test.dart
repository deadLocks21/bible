import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/fake_repositories.dart';
import '../utils/pumps.dart';

/// Ouvre le tableau de bord puis l'écran de profil.
Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('dashboardProfileButton')));
  await tester.pumpAndSettle();
}

/// Fait défiler jusqu'à la cible avant d'appuyer : l'écran de profil empile
/// trois sections, dont les dernières sortent de la fenêtre de test.
Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  if (finder.evaluate().isEmpty) {
    // La liste ne construit que ce qu'elle affiche : la section la plus basse
    // n'existe pas encore dans l'arbre.
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('Écran de profil', () {
    testWidgets('préremplit le formulaire avec le compte connecté', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(user: aUser(name: 'Jean', email: 'jean@example.com')),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openProfile(tester);

      expect(find.widgetWithText(TextFormField, 'Jean'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'jean@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('enregistre nom et e-mail', (tester) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openProfile(tester);

      await tester.enterText(
        find.byKey(const Key('profileNameField')),
        'Marie',
      );
      await _tap(tester, const Key('profileSubmitButton'));

      expect(app.profile.updatedUser?.name, 'Marie');
      expect(find.byKey(const Key('profileSavedLabel')), findsOneWidget);
    });

    testWidgets('affiche l\'erreur du serveur sur le champ concerné', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
        profile: FakeProfileRepository(
          failure: const ProfileException(
            'Vérifiez les informations saisies.',
            fieldErrors: {'email': 'Cette adresse est déjà utilisée.'},
          ),
        ),
      );
      await _openProfile(tester);

      await _tap(tester, const Key('profileSubmitButton'));

      expect(find.text('Cette adresse est déjà utilisée.'), findsOneWidget);
    });

    testWidgets('change le mot de passe et vide les champs', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openProfile(tester);

      await tester.enterText(
        find.byKey(const Key('currentPasswordField')),
        'ancien',
      );
      await tester.enterText(
        find.byKey(const Key('newPasswordField')),
        'nouveau',
      );
      await tester.enterText(
        find.byKey(const Key('newPasswordConfirmationField')),
        'nouveau',
      );
      await _tap(tester, const Key('passwordSubmitButton'));

      expect(find.byKey(const Key('passwordSavedLabel')), findsOneWidget);
      final field = tester.widget<TextFormField>(
        find.byKey(const Key('currentPasswordField')),
      );
      expect(field.controller?.text, isEmpty);
    });

    testWidgets('la déconnexion ramène à l\'écran de connexion', (
      tester,
    ) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openProfile(tester);

      await tester.tap(find.byKey(const Key('signOutButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);
      expect(app.auth.signOutCalls, 1);
      expect(await app.tokenStore.read(), isNull);
    });

    testWidgets(
      'la suppression du compte demande le mot de passe puis déconnecte',
      (tester) async {
        final app = await pumpApp(
          tester,
          session: anAuthSession(),
          reading: FakeReadingRepository(board: aReadingBoard()),
        );
        await _openProfile(tester);

        await _tap(tester, const Key('deleteAccountButton'));
        await tester.enterText(
          find.byKey(const Key('deleteAccountPasswordField')),
          'secret',
        );
        await tester.tap(find.byKey(const Key('deleteAccountConfirmButton')));
        await tester.pumpAndSettle();

        expect(app.profile.deletedWithPassword, 'secret');
        expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);
        expect(await app.tokenStore.read(), isNull);
      },
    );

    testWidgets('un mot de passe erroné laisse la boîte de dialogue ouverte', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
        profile: FakeProfileRepository(
          failure: const ProfileException(
            'Vérifiez les informations saisies.',
            fieldErrors: {'password': 'Le mot de passe est incorrect.'},
          ),
        ),
      );
      await _openProfile(tester);

      await _tap(tester, const Key('deleteAccountButton'));
      await tester.enterText(
        find.byKey(const Key('deleteAccountPasswordField')),
        'faux',
      );
      await tester.tap(find.byKey(const Key('deleteAccountConfirmButton')));
      await tester.pumpAndSettle();

      expect(find.text('Le mot de passe est incorrect.'), findsOneWidget);
      expect(find.byKey(const Key('deleteAccountConfirmButton')), findsOneWidget);
    });
  });
}
