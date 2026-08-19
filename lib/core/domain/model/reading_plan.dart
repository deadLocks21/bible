/// Plan de lecture assigné à l'utilisateur.
class ReadingPlan {
  final String id;
  final String name;

  /// Référence de la source du plan (URL ou intitulé), telle que saisie côté
  /// serveur.
  final String source;

  const ReadingPlan({
    required this.id,
    required this.name,
    required this.source,
  });
}
