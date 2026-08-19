/// Échec de chargement ou de mise à jour du plan de lecture.
class ReadingException implements Exception {
  final String message;

  const ReadingException(this.message);

  @override
  String toString() => 'ReadingException: $message';
}

/// Aucun plan de lecture actif n'est assigné à l'utilisateur (`no_active_plan`).
///
/// Cas nominal et non une panne : l'assignation se fait côté serveur, via la
/// commande `reading-plan:assign`. L'écran l'affiche comme un état à part
/// entière plutôt que comme une erreur.
class NoActivePlanException extends ReadingException {
  const NoActivePlanException(super.message);
}
