/// Vidéo YouTube couvrant un chapitre de la Bible en français.
class BibleChapterVideo {
  /// Identifiant YouTube de la vidéo (pas l'identifiant en base).
  final String youtubeVideoId;

  /// Nom canonique du livre, ex. « Genèse ».
  final String book;

  final int chapter;

  const BibleChapterVideo({
    required this.youtubeVideoId,
    required this.book,
    required this.chapter,
  });

  /// Libellé affiché sur le bouton du chapitre, ex. « Genèse 1 ».
  String get label => '$book $chapter';
}
