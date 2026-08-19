import 'package:bible/core/application/dtos/user.dto.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/infrastructure/profile/providers/profile.service_provider.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/widgets/error_banner.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Formulaire « Informations du profil », pendant de
/// `Pages/Profile/Partials/UpdateProfileInformationForm.tsx`.
class UpdateProfileForm extends ConsumerStatefulWidget {
  final UserDto user;

  const UpdateProfileForm({super.key, required this.user});

  @override
  ConsumerState<UpdateProfileForm> createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends ConsumerState<UpdateProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _submitting = false;
  ProfileUpdateFailure? _error;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        .updateProfile
        .execute(name: _nameController.text, email: _emailController.text);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      switch (result) {
        case ProfileUpdated(:final user):
          _saved = true;
          if (user != null) {
            // L'en-tête du profil affiche le nom : on le rafraîchit sans
            // attendre un rechargement de l'application.
            ref.read(authNotifierProvider.notifier).refreshUser(user);
          }
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
              key: const Key('profileErrorBanner'),
              message: _error!.message,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: const Key('profileNameField'),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom',
              errorText: _error?.fieldErrors['name'],
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Entrez votre nom'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('profileEmailField'),
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _error?.fieldErrors['email'],
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Entrez votre adresse e-mail'
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                key: const Key('profileSubmitButton'),
                onPressed: _submitting ? null : _submit,
                child: const Text('Enregistrer'),
              ),
              if (_saved) ...[
                const SizedBox(width: 12),
                Text(
                  'Enregistré.',
                  key: const Key('profileSavedLabel'),
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
