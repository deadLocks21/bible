import 'package:bible/core/domain/model/bible_chapter_video.dart';

/// Projection d'une vidéo-chapitre pour l'UI : l'identifiant à donner au
/// lecteur, et le libellé déjà composé du bouton correspondant.
class ChapterVideoDto {
  final String youtubeVideoId;
  final String label;

  const ChapterVideoDto({required this.youtubeVideoId, required this.label});

  factory ChapterVideoDto.fromDomain(BibleChapterVideo video) => ChapterVideoDto(
    youtubeVideoId: video.youtubeVideoId,
    label: video.label,
  );
}
