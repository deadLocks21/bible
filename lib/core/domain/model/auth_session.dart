import 'package:bible/core/domain/model/user.dart';

/// Session d'authentification : le jeton personnel émis par l'API et
/// l'utilisateur auquel il appartient.
///
/// Contrairement à un JWT, le jeton Sanctum n'a pas de date d'expiration : il
/// vit jusqu'à sa révocation (déconnexion, changement de mot de passe depuis un
/// autre appareil, suppression du compte). C'est donc le `401 invalid_token`
/// renvoyé par l'API qui fait foi, pas une échéance calculée côté client.
class AuthSession {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  AuthSession copyWith({User? user}) =>
      AuthSession(token: token, user: user ?? this.user);
}
