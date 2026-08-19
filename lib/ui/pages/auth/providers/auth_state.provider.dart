import 'package:bible/core/application/dtos/user.dto.dart';
import 'package:bible/core/application/usecases/sign_in.usecase.dart';
import 'package:bible/core/application/usecases/sign_up.usecase.dart';
import 'package:bible/infrastructure/auth/providers/auth.service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État du flux d'authentification : vérification d'une session persistée, puis
/// connecté ou non.
sealed class AuthState {
  const AuthState();
}

/// Vérification d'une éventuelle session persistée, au démarrage.
class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// Aucune session : l'utilisateur doit se connecter ou créer un compte.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// L'utilisateur est connecté.
class AuthAuthenticated extends AuthState {
  final UserDto user;

  const AuthAuthenticated(this.user);
}

/// Échec d'une soumission de formulaire d'authentification, renvoyé au
/// formulaire plutôt que porté par l'état global : il concerne une saisie, pas
/// la session.
class AuthFormError {
  final String message;

  /// Messages par champ (`name`, `email`, `password`,
  /// `password_confirmation`), quand le serveur les a détaillés.
  final Map<String, String> fieldErrors;

  const AuthFormError(this.message, {this.fieldErrors = const {}});
}

/// Notifier du flux d'authentification.
///
/// Au démarrage il restaure la session persistée (connexion automatique). C'est
/// lui, et non les endpoints, qui conditionne l'accès aux écrans internes — cf.
/// `AuthGate`.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Restaure une éventuelle session persistée avant d'afficher la connexion.
    _restore();
    return const AuthInitializing();
  }

  Future<void> _restore() async {
    final session = await ref
        .read(authServiceProvider)
        .restoreSession
        .execute();
    state = session == null
        ? const AuthUnauthenticated()
        : AuthAuthenticated(UserDto.fromDomain(session.user));
  }

  /// Connexion. Renvoie `null` en cas de succès, sinon l'erreur à afficher.
  Future<AuthFormError?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .signIn
        .execute(email: email, password: password);
    return switch (result) {
      SignInSuccess(:final session) => () {
        state = AuthAuthenticated(UserDto.fromDomain(session.user));
        return null;
      }(),
      SignInFailure(:final message, :final fieldErrors) => AuthFormError(
        message,
        fieldErrors: fieldErrors,
      ),
    };
  }

  /// Création de compte. Renvoie `null` en cas de succès, sinon l'erreur à
  /// afficher.
  Future<AuthFormError?> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .signUp
        .execute(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    return switch (result) {
      SignUpSuccess(:final session) => () {
        state = AuthAuthenticated(UserDto.fromDomain(session.user));
        return null;
      }(),
      SignUpFailure(:final message, :final fieldErrors) => AuthFormError(
        message,
        fieldErrors: fieldErrors,
      ),
    };
  }

  /// Déconnexion volontaire. L'état bascule d'abord : l'appel réseau de
  /// révocation ne doit pas retenir l'utilisateur sur un écran dont il veut
  /// sortir.
  Future<void> signOut() async {
    state = const AuthUnauthenticated();
    await ref.read(authServiceProvider).signOut.execute();
  }

  /// Répercute une mise à jour du profil sur l'état affiché (nom, e-mail).
  void refreshUser(UserDto user) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(user);
    }
  }

  /// Session révoquée côté serveur (401) ou compte supprimé : le jeton local a
  /// déjà été purgé, il ne reste qu'à repasser à l'écran de connexion.
  void onSessionRevoked() => state = const AuthUnauthenticated();
}

/// Provider du notifier d'authentification.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
