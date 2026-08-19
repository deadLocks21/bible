import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/model/user.dart';

/// Contrat d'authentification par e-mail et mot de passe, calqué sur l'API
/// (cf. `api/API.md`) : `POST /api/auth/login`, `/register`, `/logout`.
///
/// Toutes les méthodes lèvent une `AuthException` porteuse d'un message prêt à
/// afficher en cas d'échec.
abstract interface class AuthRepository {
  /// Échange un couple e-mail / mot de passe contre une session.
  Future<AuthSession> signIn({required String email, required String password});

  /// Crée un compte et renvoie la session émise dans la foulée.
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Révoque le jeton courant côté serveur.
  Future<void> signOut();

  /// Utilisateur porteur du jeton courant, pour valider une session restaurée
  /// au démarrage.
  Future<User> me();
}
