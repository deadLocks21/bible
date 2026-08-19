import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/pages/profile/widgets/delete_account_form.widget.dart';
import 'package:bible/ui/pages/profile/widgets/update_password_form.widget.dart';
import 'package:bible/ui/pages/profile/widgets/update_profile_form.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de gestion du compte, pendant de `Pages/Profile/Edit.tsx`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      // La session vient de disparaître (déconnexion, compte supprimé, jeton
      // révoqué) : `AuthGate` va reprendre la main, cet écran n'a plus lieu
      // d'être.
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            key: const Key('signOutButton'),
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Informations du profil',
            child: UpdateProfileForm(user: authState.user),
          ),
          _Section(
            title: 'Modifier le mot de passe',
            child: const UpdatePasswordForm(),
          ),
          const _Section(
            title: 'Supprimer le compte',
            child: DeleteAccountForm(),
          ),
        ],
      ),
    );
  }
}

/// Déconnecte, puis dépile jusqu'à la racine.
///
/// Sans ce dépilement, `AuthGate` reprendrait bien la main sous la pile, mais
/// l'écran de profil resterait affiché par-dessus — vidé de son contenu,
/// puisqu'il n'y a plus de session.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final navigator = Navigator.of(context);
  await ref.read(authNotifierProvider.notifier).signOut();
  navigator.popUntil((route) => route.isFirst);
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
