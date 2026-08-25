import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/widgets/error_banner.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de création de compte, pendant de `Pages/Auth/Register.tsx` côté web.
///
/// Ouvert par-dessus l'écran de connexion : en cas de succès, il se referme
/// pour laisser `AuthGate` — qui a déjà basculé sur l'état connecté — présenter
/// le tableau de bord.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _submitting = false;
  AuthFormError? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final error = await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmationController.text,
        );

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Le titre vit dans la page, comme sur l'écran de
                    // connexion : rien au-dessus, autant lui donner de l'air.
                    Text(
                      'Créer un compte',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quelques instants, et le plan est à vous.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ...[
                      ErrorBanner(
                        key: const Key('authErrorBanner'),
                        message: _error!.message,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      key: const Key('registerNameField'),
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        errorText: _error?.fieldErrors['name'],
                      ),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Entrez votre nom'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerEmailField'),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'jean.dupont@example.com',
                        errorText: _error?.fieldErrors['email'],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Entrez votre adresse e-mail'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerPasswordField'),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        errorText: _error?.fieldErrors['password'],
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Choisissez un mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerPasswordConfirmationField'),
                      controller: _confirmationController,
                      decoration: InputDecoration(
                        labelText: 'Confirmation du mot de passe',
                        errorText:
                            _error?.fieldErrors['password_confirmation'],
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitting ? null : _submit(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Confirmez votre mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('registerSubmitButton'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Créer le compte'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
