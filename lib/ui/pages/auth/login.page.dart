import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/pages/auth/register.page.dart';
import 'package:bible/ui/pages/settings/settings.page.dart';
import 'package:bible/ui/widgets/error_banner.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de connexion, pendant de `Pages/Auth/Login.tsx` côté web.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  AuthFormError? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    // En cas de succès, `AuthGate` a déjà remplacé cet écran : ne rien toucher.
    if (!mounted || error == null) return;
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('loginSettingsButton'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Réglages',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
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
                    // Le titre vit dans la page, pas dans la barre : l'écran
                    // n'a rien au-dessus de lui, autant lui donner de l'air.
                    Text(
                      'Bible',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reprenez votre plan de lecture.',
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
                      key: const Key('loginEmailField'),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'jean.dupont@example.com',
                        errorText: _error?.fieldErrors['email'],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Entrez votre adresse e-mail'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('loginPasswordField'),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        errorText: _error?.fieldErrors['password'],
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitting ? null : _submit(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez votre mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('loginSubmitButton'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Connexion'),
                    ),
                    const SizedBox(height: 24),
                    // `Wrap` plutôt que `Row` : sur un écran étroit ou avec
                    // une police agrandie, la phrase et le lien passent à la
                    // ligne au lieu de déborder.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          key: const Key('loginRegisterLink'),
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                ),
                          child: const Text('Créer un compte'),
                        ),
                      ],
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
