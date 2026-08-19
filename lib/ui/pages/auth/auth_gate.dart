import 'package:bible/ui/pages/auth/login.page.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/pages/dashboard/dashboard.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Racine de l'application : ne laisse atteindre le plan de lecture qu'une fois
/// l'utilisateur authentifié.
///
/// Les endpoints sont eux aussi protégés côté serveur ; ce garde évite
/// simplement d'afficher un écran qui ne pourrait rien charger.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return switch (authState) {
      AuthInitializing() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthUnauthenticated() => const LoginPage(),
      AuthAuthenticated() => const DashboardPage(),
    };
  }
}
