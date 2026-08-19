import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/infrastructure/profile/providers/profile.service_provider.dart';
import 'package:bible/ui/widgets/error_banner.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Formulaire « Modifier le mot de passe », pendant de
/// `Pages/Profile/Partials/UpdatePasswordForm.tsx`.
class UpdatePasswordForm extends ConsumerStatefulWidget {
  const UpdatePasswordForm({super.key});

  @override
  ConsumerState<UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends ConsumerState<UpdatePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _submitting = false;
  ProfileUpdateFailure? _error;
  bool _saved = false;

  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
      _saved = false;
    });

    final result = await ref
        .read(profileServiceProvider)
        .updatePassword
        .execute(
          currentPassword: _currentController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmationController.text,
        );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      switch (result) {
        case ProfileUpdated():
          _saved = true;
          // Les champs sont vidés : laisser un mot de passe en clair dans un
          // champ après coup n'a aucune raison d'être.
          _currentController.clear();
          _passwordController.clear();
          _confirmationController.clear();
        case ProfileUpdateFailure():
          _error = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            ErrorBanner(
              key: const Key('passwordErrorBanner'),
              message: _error!.message,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: const Key('currentPasswordField'),
            controller: _currentController,
            decoration: InputDecoration(
              labelText: 'Mot de passe actuel',
              errorText: _error?.fieldErrors['current_password'],
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Entrez votre mot de passe actuel'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('newPasswordField'),
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              errorText: _error?.fieldErrors['password'],
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Choisissez un nouveau mot de passe'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('newPasswordConfirmationField'),
            controller: _confirmationController,
            decoration: InputDecoration(
              labelText: 'Confirmation',
              errorText: _error?.fieldErrors['password_confirmation'],
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Confirmez le nouveau mot de passe'
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                key: const Key('passwordSubmitButton'),
                onPressed: _submitting ? null : _submit,
                child: const Text('Enregistrer'),
              ),
              if (_saved) ...[
                const SizedBox(width: 12),
                Text(
                  'Mot de passe modifié.',
                  key: const Key('passwordSavedLabel'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
