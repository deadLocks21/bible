import 'package:bible/core/domain/model/user.dart';

/// Contrat des opérations sur le compte, calqué sur l'API
/// (`PATCH /api/profile`, `PUT /api/profile/password`, `DELETE /api/profile`).
///
/// Toutes les méthodes lèvent une `ProfileException` porteuse d'un message prêt
/// à afficher en cas d'échec.
abstract interface class ProfileRepository {
  /// Met à jour nom et e-mail, et renvoie l'utilisateur à jour.
  Future<User> updateProfile({required String name, required String email});

  /// Change le mot de passe. Les jetons des autres appareils sont révoqués côté
  /// serveur ; celui de l'appareil courant reste valide.
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// Supprime le compte après confirmation du mot de passe.
  Future<void> deleteAccount({required String password});
}
