import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/utils/backend_url.dart';
import 'package:bible/infrastructure/http/providers/api_base_url.provider.dart';
import 'package:bible/infrastructure/settings/providers/app_version.provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Réglages de l'application : thème, serveur visé, version installée.
///
/// Le serveur n'a pas d'équivalent web — l'application y est servie par le
/// serveur lui-même. Il est ici pour les cas où le binaire doit viser autre
/// chose que le serveur compilé dans le build : recette, instance locale.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final baseUrl = ref.watch(apiBaseUrlProvider);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          const _SectionHeader('Apparence'),
          RadioGroup<AppThemeMode>(
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
                    title: Text(_themeLabel(mode)),
                  ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Serveur'),
          ListTile(
            key: const Key('serverUrlTile'),
            title: const Text('URL du serveur'),
            subtitle: Text(baseUrl),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editServerUrl(context, ref, baseUrl),
          ),
          if (!ref.read(apiBaseUrlProvider.notifier).isDefault)
            ListTile(
              key: const Key('resetServerUrlTile'),
              title: const Text('Revenir au serveur par défaut'),
              leading: const Icon(Icons.restart_alt),
              onTap: () => ref.read(apiBaseUrlProvider.notifier).reset(),
            ),
          const Divider(),
          const _SectionHeader('À propos'),
          ListTile(
            key: const Key('appVersionTile'),
            title: const Text('Version'),
            subtitle: Text(
              switch (version) {
                AsyncData(:final value) => value,
                AsyncError() => 'Indisponible',
                _ => '…',
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editServerUrl(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => _ServerUrlDialog(initialValue: current),
    );
    if (url != null) {
      await ref.read(apiBaseUrlProvider.notifier).update(url);
    }
  }

  String _themeLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => 'Clair',
    AppThemeMode.dark => 'Sombre',
    AppThemeMode.system => 'Système',
  };
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
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
