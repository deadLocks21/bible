/// Utilitaires autour de l'URL du serveur.
///
/// L'URL retenue est une **origine** seule — schéma + hôte + port non standard
/// éventuel, sans chemin ni requête ni fragment. Les chemins d'API s'y ajoutent
/// comme chemins relatifs de Dio (cf. [BackendEndpoints]).
class BackendUrl {
  const BackendUrl._();

  /// Normalise [input] en son origine (`schéma://hôte[:port]`), en supprimant
  /// chemin, requête, fragment et barre oblique finale. Renvoie l'entrée
  /// nettoyée telle quelle lorsqu'elle n'est pas analysable comme une URL
  /// `http`/`https` avec un hôte : une valeur invalide n'est jamais
  /// silencieusement transformée en autre chose.
  static String normalize(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return trimmed;
    }
    // `Uri` masque le port quand il vaut celui par défaut du schéma (80/443) :
    // un port explicite est préservé, le cas courant reste propre.
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.port).toString();
  }
}
