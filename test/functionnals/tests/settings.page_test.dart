import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../builders/builders.dart';
import '../utils/fake_repositories.dart';
import '../utils/pumps.dart';

/// Ouvre les réglages depuis l'écran de connexion — le chemin emprunté avant
/// d'avoir un compte, quand il s'agit de changer de serveur.
Future<void> _openFromLogin(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('loginSettingsButton')));
  await tester.pumpAndSettle();
}

/// Ouvre les réglages depuis le tableau de bord, session en cours.
Future<void> _openFromDashboard(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('dashboardSettingsButton')));
  await tester.pumpAndSettle();
}

/// La liste des réglages, et non la première venue : l'écran est empilé
/// au-dessus du tableau de bord, dont la liste vient avant dans l'arbre.
/// Reconstruit à chaque appel — un `Finder` mémorise ses résultats, et le
/// partager entre deux tests le ferait pointer sur un arbre disparu.
///
/// `first` : les champs de saisie embarquent eux aussi un `Scrollable`, celui
/// de la liste vient avant eux.
Finder _settingsScrollable() => find
    .descendant(
      of: find.byKey(const Key('settingsList')),
      matching: find.byType(Scrollable),
    )
    .first;

/// Fait défiler jusqu'à la cible : connecté, l'écran empile assez de sections
/// pour que les dernières sortent de la fenêtre de test — et la liste ne
/// construit que ce qu'elle affiche.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: _settingsScrollable(),
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
}

/// Fait défiler jusqu'à la cible avant d'appuyer.
Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: _settingsScrollable(),
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Bible',
      packageName: 'fr.dtfh.bible',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  group('Réglages — préférences de l\'application', () {
    testWidgets('sont accessibles avant toute connexion', (tester) async {
      await pumpApp(tester);
      await _openFromLogin(tester);

      expect(find.text('JEU DE COULEURS'), findsOneWidget);
      expect(find.text('APPARENCE'), findsOneWidget);
      await _scrollTo(tester, find.byKey(const Key('appVersionTile')));
      expect(find.byKey(const Key('appVersionTile')), findsOneWidget);
      // Rien qui suppose un compte : ni formulaire, ni déconnexion.
      expect(find.byKey(const Key('profileNameField')), findsNothing);
      expect(find.byKey(const Key('deleteAccountButton')), findsNothing);
      expect(find.byKey(const Key('signOutButton')), findsNothing);
    });

    testWidgets('enregistrent le thème choisi', (tester) async {
      final app = await pumpApp(tester);
      await _openFromLogin(tester);

      await _tap(tester, const Key('themeMode_dark'));

      expect(app.theme.mode, AppThemeMode.dark);
    });

    testWidgets('enregistrent le jeu de couleurs choisi', (tester) async {
      final app = await pumpApp(tester);
      await _openFromLogin(tester);

      await _tap(tester, const Key('palette_mono'));

      expect(app.theme.palette, AppPalette.mono);
      // La palette et l'ambiance sont deux réglages distincts : choisir l'une
      // ne touche pas à l'autre.
      expect(app.theme.mode, AppThemeMode.system);
    });

    testWidgets('affichent la version installée', (tester) async {
      await pumpApp(tester);
      await _openFromLogin(tester);

      await _scrollTo(tester, find.text('1.2.3 (45)'));
      expect(find.text('1.2.3 (45)'), findsOneWidget);
    });

  });

  group('Réglages — compte', () {
    testWidgets('préremplissent le formulaire avec le compte connecté', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(
          user: aUser(name: 'Jean', email: 'jean@example.com'),
        ),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openFromDashboard(tester);

      // La section du profil est passée sous la ligne de flottaison depuis que
      // le jeu de couleurs occupe le haut de l'écran.
      await tester.drag(
        find.byKey(const Key('settingsList')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Jean'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'jean@example.com'),
        findsOneWidget,
      );
      // Les préférences restent accessibles depuis le même écran, plus bas.
      await _scrollTo(tester, find.text('APPARENCE'));
      expect(find.text('APPARENCE'), findsOneWidget);
    });

    testWidgets('enregistrent nom et e-mail', (tester) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openFromDashboard(tester);

      await _scrollTo(tester, find.byKey(const Key('profileNameField')));
      await tester.enterText(
        find.byKey(const Key('profileNameField')),
        'Marie',
      );
      await _tap(tester, const Key('profileSubmitButton'));

      expect(app.profile.updatedUser?.name, 'Marie');
      expect(find.byKey(const Key('profileSavedLabel')), findsOneWidget);
    });

    testWidgets('affichent l\'erreur du serveur sur le champ concerné', (
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
      await _openFromDashboard(tester);

      await _tap(tester, const Key('profileSubmitButton'));

      expect(find.text('Cette adresse est déjà utilisée.'), findsOneWidget);
    });

    testWidgets('changent le mot de passe et vident les champs', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );
      await _openFromDashboard(tester);

      await _scrollTo(tester, find.byKey(const Key('currentPasswordField')));
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
      await _openFromDashboard(tester);

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
        await _openFromDashboard(tester);

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
      await _openFromDashboard(tester);

      await _tap(tester, const Key('deleteAccountButton'));
      await tester.enterText(
        find.byKey(const Key('deleteAccountPasswordField')),
        'faux',
      );
      await tester.tap(find.byKey(const Key('deleteAccountConfirmButton')));
      await tester.pumpAndSettle();

      expect(find.text('Le mot de passe est incorrect.'), findsOneWidget);
      expect(
        find.byKey(const Key('deleteAccountConfirmButton')),
        findsOneWidget,
      );
    });
  });
}
