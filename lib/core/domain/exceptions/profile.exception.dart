/// Échec d'une opération sur le profil (mise à jour, mot de passe,
/// suppression) porteur d'un message prêt à afficher.
class ProfileException implements Exception {
  final String message;

  /// Erreurs de validation renvoyées par l'API, indexées par champ.
  final Map<String, String> fieldErrors;

  const ProfileException(this.message, {this.fieldErrors = const {}});

  @override
  String toString() => 'ProfileException: $message';
}
