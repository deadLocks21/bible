/// Régularité et avancement de l'utilisateur sur son plan actif.
///
/// Une série est une suite de journées consécutives comptant au moins une
/// lecture : ce qui est mesuré est la régularité, pas le volume. Le découpage
/// des journées est décidé par le serveur.
class ReadingStats {
  /// Jours consécutifs lus jusqu'à aujourd'hui. Tolère de n'avoir pas encore lu
  /// aujourd'hui : la série ne casse qu'après une journée entière sans lecture.
  final int currentStreak;

  /// Meilleure série jamais atteinte.
  final int longestStreak;

  /// Lectures validées sur le plan actif.
  final int readCount;

  /// Nombre total de lectures que compte le plan.
  final int planEntryCount;

  /// Première lecture validée, `null` tant qu'il n'y en a aucune.
  final DateTime? firstReadAt;

  const ReadingStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.readCount,
    required this.planEntryCount,
    this.firstReadAt,
  });

  /// Avancement dans le plan, entre 0 et 1. Vaut 0 pour un plan vide, faute de
  /// dénominateur.
  double get progress =>
      planEntryCount == 0 ? 0 : (readCount / planEntryCount).clamp(0, 1);

  /// Vrai tant qu'aucune lecture n'a été validée : il n'y a rien à raconter.
  bool get isEmpty => readCount == 0;
}
