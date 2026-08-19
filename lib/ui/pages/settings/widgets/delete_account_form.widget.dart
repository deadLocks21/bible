import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/infrastructure/profile/providers/profile.service_provider.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/widgets/error_banner.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section « Supprimer le compte », pendant du bloc correspondant de
/// `Pages/Profile/Edit.tsx`.
///
/// La suppression est irréversible : elle passe par une boîte de dialogue de
/// confirmation qui redemande le mot de passe, comme sur le web.
class DeleteAccountForm extends ConsumerWidget {
  const DeleteAccountForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Une fois votre compte supprimé, toutes ses données le sont aussi, '
          'sans retour possible.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            key: const Key('deleteAccountButton'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => _confirm(context, ref),
            child: const Text('Supprimer le compte'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted != true) return;
    // Le compte n'existe plus et la session locale a été effacée : il ne reste
    // qu'à dépiler jusqu'à la racine, où `AuthGate` présente la connexion.
    ref.read(authNotifierProvider.notifier).onSessionRevoked();
    navigator.popUntil((route) => route.isFirst);
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();

  bool _submitting = false;
  ProfileUpdateFailure? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await ref
        .read(profileServiceProvider)
        .deleteAccount
        .execute(password: _passwordController.text);

    if (!mounted) return;
    switch (result) {
      case ProfileUpdated():
        Navigator.of(context).pop(true);
      case ProfileUpdateFailure():
        setState(() {
          _submitting = false;
          _error = result;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer le compte ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirmez avec votre mot de passe. Cette action est définitive.',
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            ErrorBanner(
              key: const Key('deleteAccountErrorBanner'),
              message: _error!.message,
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            key: const Key('deleteAccountPasswordField'),
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              errorText: _error?.fieldErrors['password'],
            ),
            obscureText: true,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('deleteAccountConfirmButton'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: _submitting ? null : _submit,
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
