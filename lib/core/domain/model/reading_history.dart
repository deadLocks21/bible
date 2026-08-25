/// Une lecture déjà validée : ce qui a été lu, et quand.
class ReadingHistoryEntry {
  final String id;

  /// Passages de la lecture, ex. « Genèse 1-3 ».
  final String passages;

  /// Date à laquelle l'utilisateur a marqué la lecture comme lue.
  final DateTime readAt;

  /// Vrai pour la seule lecture que l'utilisateur peut repasser en non lue.
  ///
  /// La règle est portée par le serveur : on ne défait que la dernière lecture
  /// validée, sans quoi la progression dans le plan serait trouée.
  final bool canUnread;

  const ReadingHistoryEntry({
    required this.id,
    required this.passages,
    required this.readAt,
    this.canUnread = false,
  });
}

/// Une page d'historique, de la lecture la plus récente à la plus ancienne.
class ReadingHistory {
  final List<ReadingHistoryEntry> entries;

  /// Numéro de la page servie, à partir de 1.
  final int page;

  /// Vrai quand une page suivante existe.
  final bool hasMore;

  const ReadingHistory({
    required this.entries,
    required this.page,
    required this.hasMore,
  });

  /// Page vide : aucune lecture validée pour l'instant.
  bool get isEmpty => entries.isEmpty;
}
