/// Échec d'authentification porteur d'un message prêt à afficher.
///
/// Les implémentations de `AuthRepository` traduisent le `code` machine de
/// l'API (cf. `api/API.md`) en message français ; l'UI se contente d'afficher
/// [message] sans rien réinterpréter.
class AuthException implements Exception {
  final String message;

  /// Erreurs de validation renvoyées par l'API, indexées par champ
  /// (`name`, `email`, `password`). Vide hors `422 invalid_request`.
  final Map<String, String> fieldErrors;

  const AuthException(this.message, {this.fieldErrors = const {}});

  @override
  String toString() => 'AuthException: $message';
}
