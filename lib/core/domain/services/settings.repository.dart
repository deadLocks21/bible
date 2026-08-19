/// Stockage des réglages de l'application.
abstract interface class SettingsRepository {
  /// URL du serveur choisie par l'utilisateur, ou `null` si aucune n'a été
  /// enregistrée — auquel cas c'est la valeur de compilation qui s'applique.
  Future<String?> getBackendUrl();

  /// Enregistre l'URL du serveur.
  Future<void> setBackendUrl(String url);

  /// Oublie l'URL enregistrée et revient à la valeur de compilation.
  Future<void> clearBackendUrl();
}
