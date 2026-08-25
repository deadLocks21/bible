import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/ui/theme/app_theme_data.dart';
import 'package:bible/infrastructure/settings/providers/app_version.provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/pages/settings/widgets/delete_account_form.widget.dart';
import 'package:bible/ui/pages/settings/widgets/update_password_form.widget.dart';
import 'package:bible/ui/pages/settings/widgets/update_profile_form.widget.dart';
import 'package:bible/ui/widgets/section_label.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran unique de configuration : le compte et les préférences de
/// l'application.
///
/// Il regroupe l'équivalent de `Pages/Profile/Edit.tsx` côté web et les
/// réglages propres au mobile (thème, version installée) — le web n'a besoin
/// ni de l'un ni de l'autre, l'application y suivant le thème du navigateur.
///
/// Il est atteignable **avant** la connexion, depuis l'écran de connexion, d'où
/// l'apparence se règle sans compte. Les sections liées au compte
/// n'apparaissent donc que lorsqu'une session existe.
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
        key: const Key('settingsList'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Section(title: 'Jeu de couleurs', child: const _PaletteChoice()),
          _Section(title: 'Apparence', child: const _ThemeChoice()),
          if (user != null) ...[
            _Section(
              title: 'Informations du profil',
              child: UpdateProfileForm(user: user),
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
          _Section(title: 'À propos', child: const _AppVersion()),
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

/// Choix du jeu de couleurs, indépendant du clair/sombre réglé juste en
/// dessous : chaque palette existe dans les deux ambiances.
class _PaletteChoice extends ConsumerWidget {
  const _PaletteChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    return RadioGroup<AppPalette>(
      groupValue: palette.value ?? AppThemeData.defaultPalette,
      onChanged: (selected) => selected == null
          ? null
          : ref.read(paletteProvider.notifier).setPalette(selected),
      child: Column(
        children: [
          for (final value in AppPalette.values)
            RadioListTile<AppPalette>(
              key: Key('palette_${value.name}'),
              value: value,
              title: Text(_label(value)),
              subtitle: Text(_description(value)),
              secondary: _Swatch(palette: value),
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  String _label(AppPalette palette) => switch (palette) {
    AppPalette.paper => 'Papier & encre',
    AppPalette.night => 'Nuit calme',
    AppPalette.mono => 'Monochrome',
  };

  String _description(AppPalette palette) => switch (palette) {
    AppPalette.paper => 'Ivoire chaud, accent terre cuite',
    AppPalette.night => 'Ardoise profonde, accent bleu',
    AppPalette.mono => 'Noir et blanc, accent vert',
  };
}

/// Trois pastilles : le fond clair, l'accent, le fond sombre. De quoi
/// reconnaître une palette sans l'appliquer.
class _Swatch extends StatelessWidget {
  final AppPalette palette;

  const _Swatch({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in AppThemeData.swatchOf(palette))
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Clair, sombre, ou l'ambiance du système — quelle que soit la palette.
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
    AppThemeMode.system => 'Automatique (système)',
  };
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
    // L'intitulé sort de la carte : il annonce le bloc plutôt que d'en occuper
    // la première ligne, et l'écran se parcourt d'un coup d'œil.
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: SectionLabel(title),
          ),
          // `Material` et non un simple `Container` coloré : les `ListTile`
          // du bloc peignent leur fond et leurs ondes sur le `Material` le plus
          // proche, qu'un aplat intermédiaire masquerait.
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
