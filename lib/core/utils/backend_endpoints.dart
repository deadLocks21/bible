/// Chemins d'API, relatifs à l'origine portée par la `baseUrl` de Dio.
///
/// Tout endpoint vit ici : le jour où un chemin change, il n'y a qu'un seul
/// endroit à corriger. Cf. `api/API.md`.
class BackendEndpoints {
  const BackendEndpoints._();

  /// Création de compte (publique).
  static const String register = '/api/auth/register';

  /// Connexion e-mail + mot de passe, renvoie le jeton (publique).
  static const String login = '/api/auth/login';

  /// Révocation du jeton porté par la requête.
  static const String logout = '/api/auth/logout';

  /// Utilisateur porteur du jeton courant.
  static const String me = '/api/me';

  /// Nom et adresse e-mail du compte.
  static const String profile = '/api/profile';

  /// Changement de mot de passe.
  static const String profilePassword = '/api/profile/password';

  /// Plan actif et prochaines lectures.
  static const String readingPlan = '/api/reading-plan';

  /// Marque une lecture comme lue.
  static String readEntry(String entryId) =>
      '/api/reading-plan/entries/$entryId/read';

  /// Préfixe des routes publiques : l'intercepteur d'authentification n'y
  /// ajoute pas de jeton et n'y interprète pas les 401.
  static const String publicPrefix = '/api/auth/';

  /// Vrai pour les routes publiques d'authentification (connexion et
  /// inscription). La déconnexion, elle, est protégée : elle doit porter le
  /// jeton qu'elle révoque.
  static bool isPublic(String path) =>
      path.startsWith(publicPrefix) && !path.endsWith('/logout');
}
