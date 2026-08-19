import 'package:bible/core/application/dtos/chapter_video.dto.dart';
import 'package:bible/core/domain/model/reading_entry.dart';

/// Projection d'une lecture pour l'UI.
///
/// [canMarkAsRead] porte la règle « on n'avance dans un plan que dans
/// l'ordre » : seule la lecture du jour est marquable, les suivantes sont
/// affichées à titre indicatif.
class ReadingEntryDto {
  final String id;
  final String passages;
  final List<ChapterVideoDto> videos;
  final bool canMarkAsRead;

  const ReadingEntryDto({
    required this.id,
    required this.passages,
    required this.videos,
    required this.canMarkAsRead,
  });

  factory ReadingEntryDto.fromDomain(
    ReadingEntry entry, {
    required bool canMarkAsRead,
  }) => ReadingEntryDto(
    id: entry.id,
    passages: entry.passages,
    videos: entry.videos.map(ChapterVideoDto.fromDomain).toList(),
    canMarkAsRead: canMarkAsRead,
  );

  bool get hasVideos => videos.isNotEmpty;
}
