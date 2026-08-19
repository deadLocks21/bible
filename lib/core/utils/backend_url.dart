/// Utilitaires autour de l'URL du serveur.
///
/// L'URL stockée est une **origine** seule — schéma + hôte + port non standard
/// éventuel, sans chemin ni requête ni fragment. Les chemins d'API sont
/// ajoutés au moment de l'appel (cf. [BackendEndpoints]) via [join], de sorte
/// qu'un nouvel endpoint ne demande jamais de toucher à la valeur stockée.
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

  /// Valide une URL saisie par l'utilisateur. Renvoie `null` quand elle est
  /// une origine valide, sinon un message court expliquant le problème.
  static String? validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'L\'URL ne peut pas être vide';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Entrez une URL valide commençant par http:// ou https://';
    }
    if (uri.host.isEmpty) {
      return 'L\'URL doit contenir un nom de domaine';
    }
    final hasPath = uri.path.isNotEmpty && uri.path != '/';
    if (hasPath || uri.hasQuery || uri.hasFragment) {
      return 'Saisissez uniquement le domaine, sans chemin '
          '(ex : https://bible.dtfh.fr)';
    }
    return null;
  }

  /// Assemble une origine et un [path] d'API en écrasant la barre oblique
  /// intermédiaire, de sorte que `join('https://x.fr/', 'api/me')` et
  /// `join('https://x.fr', '/api/me')` donnent tous deux `https://x.fr/api/me`.
  static String join(String base, String path) {
    final origin = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$origin$suffix';
  }
}
