import 'package:bible/core/domain/model/auth_session.dart';

/// Stockage local de la session d'authentification.
abstract interface class AuthTokenStore {
  /// Lit la session stockée, ou `null` si aucune.
  Future<AuthSession?> read();

  /// Persiste la session.
  Future<void> write(AuthSession session);

  /// Supprime la session stockée (déconnexion, jeton révoqué).
  Future<void> clear();
}
