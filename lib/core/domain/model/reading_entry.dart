import 'package:bible/core/domain/model/bible_chapter_video.dart';

/// Une lecture du plan : les passages à lire, et les vidéos-chapitres qui les
/// couvrent, dans l'ordre de lecture.
class ReadingEntry {
  final String id;

  /// Passages de la lecture, ex. « Genèse 1-3 ».
  final String passages;

  final List<BibleChapterVideo> videos;

  const ReadingEntry({
    required this.id,
    required this.passages,
    this.videos = const [],
  });

  /// Vrai quand la lecture peut être écoutée dans l'application.
  bool get hasVideos => videos.isNotEmpty;
}
