import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/fake_repositories.dart';
import '../utils/pumps.dart';

void main() {
  group('Écran de connexion', () {
    testWidgets('s\'affiche quand aucune session n\'est stockée', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);
    });

    testWidgets('mène au tableau de bord après une connexion réussie', (
      tester,
    ) async {
      final app = await pumpApp(
        tester,
        auth: FakeAuthRepository(session: anAuthSession()),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );

      await tester.enterText(
        find.byKey(const Key('loginEmailField')),
        'jean@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('loginPasswordField')),
        'secret',
      );
      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Plan chronologique'), findsOneWidget);
      // La session est persistée : le prochain démarrage n'aura pas à
      // redemander les identifiants.
      expect(await app.tokenStore.read(), isNotNull);
    });

    testWidgets('affiche le message d\'erreur du serveur et reste en place', (
      tester,
    ) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(
          failure: const AuthException('Adresse e-mail ou mot de passe incorrect.'),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('loginEmailField')),
        'jean@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('loginPasswordField')),
        'faux',
      );
      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('authErrorBanner')), findsOneWidget);
      expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);
    });

    testWidgets('n\'appelle pas le serveur quand un champ est vide', (
      tester,
    ) async {
      final app = await pumpApp(tester);

      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Entrez votre adresse e-mail'), findsOneWidget);
      expect(find.byKey(const Key('authErrorBanner')), findsNothing);
      expect(app.auth.signOutCalls, 0);
    });

    testWidgets('ouvre le formulaire de création de compte', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const Key('loginRegisterLink')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('registerSubmitButton')), findsOneWidget);
    });

    testWidgets(
      'la création de compte referme le formulaire et connecte l\'utilisateur',
      (tester) async {
        await pumpApp(
          tester,
          auth: FakeAuthRepository(session: anAuthSession()),
          reading: FakeReadingRepository(board: aReadingBoard()),
        );

        await tester.tap(find.byKey(const Key('loginRegisterLink')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('registerNameField')),
          'Jean',
        );
        await tester.enterText(
          find.byKey(const Key('registerEmailField')),
          'jean@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('registerPasswordField')),
          'secret',
        );
        await tester.enterText(
          find.byKey(const Key('registerPasswordConfirmationField')),
          'secret',
        );
        await tester.tap(find.byKey(const Key('registerSubmitButton')));
        await tester.pumpAndSettle();

        expect(find.text('Plan chronologique'), findsOneWidget);
      },
    );

    testWidgets(
      'la confirmation divergente est refusée sans appeler le serveur',
      (tester) async {
        final app = await pumpApp(tester, auth: FakeAuthRepository());

        await tester.tap(find.byKey(const Key('loginRegisterLink')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('registerNameField')),
          'Jean',
        );
        await tester.enterText(
          find.byKey(const Key('registerEmailField')),
          'jean@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('registerPasswordField')),
          'secret',
        );
        await tester.enterText(
          find.byKey(const Key('registerPasswordConfirmationField')),
          'autre',
        );
        await tester.tap(find.byKey(const Key('registerSubmitButton')));
        await tester.pumpAndSettle();

        expect(find.text('Les mots de passe ne correspondent pas.'), findsWidgets);
        expect(await app.tokenStore.read(), isNull);
      },
    );
  });
}
