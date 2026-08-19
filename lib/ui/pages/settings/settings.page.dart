import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/utils/backend_url.dart';
import 'package:bible/infrastructure/http/providers/api_base_url.provider.dart';
import 'package:bible/infrastructure/settings/providers/app_version.provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/pages/settings/widgets/delete_account_form.widget.dart';
import 'package:bible/ui/pages/settings/widgets/update_password_form.widget.dart';
import 'package:bible/ui/pages/settings/widgets/update_profile_form.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran unique de configuration : le compte et les préférences de
/// l'application.
///
/// Il regroupe l'équivalent de `Pages/Profile/Edit.tsx` côté web et les
/// réglages propres au mobile (thème, serveur visé, version installée) — le web
/// n'a besoin ni de l'un ni de l'autre, l'application y étant servie par le
/// serveur lui-même et suivant le thème du navigateur.
///
/// Il est atteignable **avant** la connexion, depuis l'écran de connexion :
/// c'est là que se change l'URL du serveur quand le binaire doit viser autre
/// chose que le serveur compilé (recette, instance locale). Les sections liées
/// au compte n'apparaissent donc que lorsqu'une session existe.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
        actions: [
          if (user != null)
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
          if (user != null) ...[
            _Section(
              title: 'Informations du profil',
              child: UpdateProfileForm(user: user),
            ),
            _Section(
              title: 'Modifier le mot de passe',
              child: const UpdatePasswordForm(),
            ),
          ],
          _Section(title: 'Apparence', child: const _ThemeChoice()),
          _Section(title: 'Serveur', child: const _ServerChoice()),
          _Section(title: 'À propos', child: const _AppVersion()),
          if (user != null)
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
/// cet écran resterait affiché par-dessus — amputé de ses sections de compte,
/// puisqu'il n'y a plus de session.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final navigator = Navigator.of(context);
  await ref.read(authNotifierProvider.notifier).signOut();
  navigator.popUntil((route) => route.isFirst);
}

class _ThemeChoice extends ConsumerWidget {
  const _ThemeChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return RadioGroup<AppThemeMode>(
      groupValue: themeMode.value ?? AppThemeMode.system,
      onChanged: (selected) => selected == null
          ? null
          : ref.read(themeModeProvider.notifier).setThemeMode(selected),
      child: Column(
        children: [
          for (final mode in AppThemeMode.values)
            RadioListTile<AppThemeMode>(
              key: Key('themeMode_${mode.name}'),
              value: mode,
              title: Text(_label(mode)),
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  String _label(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => 'Clair',
    AppThemeMode.dark => 'Sombre',
    AppThemeMode.system => 'Système',
  };
}

class _ServerChoice extends ConsumerWidget {
  const _ServerChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(apiBaseUrlProvider);
    return Column(
      children: [
        ListTile(
          key: const Key('serverUrlTile'),
          contentPadding: EdgeInsets.zero,
          title: const Text('URL du serveur'),
          subtitle: Text(baseUrl),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _edit(context, ref, baseUrl),
        ),
        if (!ref.read(apiBaseUrlProvider.notifier).isDefault)
          ListTile(
            key: const Key('resetServerUrlTile'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restart_alt),
            title: const Text('Revenir au serveur par défaut'),
            onTap: () => ref.read(apiBaseUrlProvider.notifier).reset(),
          ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, String current) async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => _ServerUrlDialog(initialValue: current),
    );
    if (url != null) {
      await ref.read(apiBaseUrlProvider.notifier).update(url);
    }
  }
}

class _AppVersion extends ConsumerWidget {
  const _AppVersion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);
    return ListTile(
      key: const Key('appVersionTile'),
      contentPadding: EdgeInsets.zero,
      title: const Text('Version'),
      subtitle: Text(switch (version) {
        AsyncData(:final value) => value,
        AsyncError() => 'Indisponible',
        _ => '…',
      }),
    );
  }
}

/// Bloc titré, pour que les préférences et les formulaires de compte se
/// présentent de la même façon dans la liste.
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

/// Saisie de l'URL du serveur. La validation refuse tout ce qui n'est pas une
/// origine (`https://exemple.fr`) : les chemins d'API sont ajoutés par le code.
class _ServerUrlDialog extends StatefulWidget {
  final String initialValue;

  const _ServerUrlDialog({required this.initialValue});

  @override
  State<_ServerUrlDialog> createState() => _ServerUrlDialogState();
}

class _ServerUrlDialogState extends State<_ServerUrlDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = BackendUrl.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('URL du serveur'),
      content: TextField(
        key: const Key('serverUrlField'),
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'https://bible.dtfh.fr',
          errorText: _error,
        ),
        keyboardType: TextInputType.url,
        autocorrect: false,
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('serverUrlSubmitButton'),
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
