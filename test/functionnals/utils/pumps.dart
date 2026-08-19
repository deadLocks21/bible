import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/infrastructure/auth/in_memory.auth_token_store.dart';
import 'package:bible/infrastructure/auth/providers/auth.repository_provider.dart';
import 'package:bible/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:bible/infrastructure/profile/providers/profile.repository_provider.dart';
import 'package:bible/infrastructure/reading/providers/reading.repository_provider.dart';
import 'package:bible/ui/pages/auth/auth_gate.dart';
import 'package:bible/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_repositories.dart';

/// Le contexte d'un test fonctionnel : les adaptateurs de test injectés, pour
/// que le test puisse à la fois les préparer et vérifier ce qu'ils ont reçu.
class TestApp {
  final FakeAuthRepository auth;
  final FakeReadingRepository reading;
  final FakeProfileRepository profile;
  final AuthTokenStore tokenStore;

  const TestApp({
    required this.auth,
    required this.reading,
    required this.profile,
    required this.tokenStore,
  });
}

/// Monte l'application complète — depuis `AuthGate`, comme au démarrage — avec
/// des adaptateurs de test à la place des repositories HTTP.
///
/// [session] pré-remplit le stockage local : la passer revient à démarrer sur
/// un appareil déjà connecté.
Future<TestApp> pumpApp(
  WidgetTester tester, {
  AuthSession? session,
  FakeAuthRepository? auth,
  FakeReadingRepository? reading,
  FakeProfileRepository? profile,
}) async {
  final app = TestApp(
    auth: auth ?? FakeAuthRepository(),
    reading: reading ?? FakeReadingRepository(),
    profile: profile ?? FakeProfileRepository(),
    tokenStore: InMemoryAuthTokenStore(session),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(app.auth),
        readingRepositoryProvider.overrideWithValue(app.reading),
        profileRepositoryProvider.overrideWithValue(app.profile),
        authTokenStoreProvider.overrideWithValue(app.tokenStore),
      ],
      child: MaterialApp(
        theme: AppThemeData.buildLightTheme(),
        home: const AuthGate(),
      ),
    ),
  );
  // Laisse la restauration de session et le premier chargement se résoudre.
  await tester.pumpAndSettle();

  return app;
}
