import 'package:bible/core/domain/model/bible_chapter_video.dart';
import 'package:bible/core/domain/model/reading_board.dart';
import 'package:bible/core/domain/model/reading_entry.dart';
import 'package:bible/core/domain/model/reading_plan.dart';

/// Constructeurs d'objets de domaine pour les tests : des valeurs par défaut
/// plausibles, et seuls les champs qui comptent pour un test donné à préciser.
ReadingPlan aReadingPlan({
  String id = 'plan-1',
  String name = 'Plan chronologique',
  String source = 'https://example.com/plan',
}) => ReadingPlan(id: id, name: name, source: source);

BibleChapterVideo aChapterVideo({
  String youtubeVideoId = 'video-1',
  String book = 'Genèse',
  int chapter = 1,
}) => BibleChapterVideo(
  youtubeVideoId: youtubeVideoId,
  book: book,
  chapter: chapter,
);

ReadingEntry aReadingEntry({
  String id = 'entry-1',
  String passages = 'Genèse 1-3',
  List<BibleChapterVideo> videos = const [],
}) => ReadingEntry(id: id, passages: passages, videos: videos);

ReadingBoard aReadingBoard({
  ReadingPlan? plan,
  List<ReadingEntry>? entries,
}) => ReadingBoard(
  plan: plan ?? aReadingPlan(),
  entries:
      entries ??
      [
        aReadingEntry(),
        aReadingEntry(id: 'entry-2', passages: 'Genèse 4-7'),
      ],
);
