import 'package:bible/core/domain/model/reading_history.dart';

/// Projection d'une lecture passée pour l'UI.
class ReadingHistoryEntryDto {
  final String id;
  final String passages;
  final DateTime readAt;

  /// Vrai pour la seule lecture repassable en non lue (la plus récente).
  final bool canUnread;

  const ReadingHistoryEntryDto({
    required this.id,
    required this.passages,
    required this.readAt,
    required this.canUnread,
  });

  factory ReadingHistoryEntryDto.fromDomain(ReadingHistoryEntry entry) =>
      ReadingHistoryEntryDto(
        id: entry.id,
        passages: entry.passages,
        readAt: entry.readAt,
        canUnread: entry.canUnread,
      );
}

/// Une page d'historique pour l'UI.
class ReadingHistoryDto {
  final List<ReadingHistoryEntryDto> entries;
  final int page;
  final bool hasMore;

  const ReadingHistoryDto({
    required this.entries,
    required this.page,
    required this.hasMore,
  });

  factory ReadingHistoryDto.fromDomain(ReadingHistory history) =>
      ReadingHistoryDto(
        entries: history.entries.map(ReadingHistoryEntryDto.fromDomain).toList(),
        page: history.page,
        hasMore: history.hasMore,
      );

  bool get isEmpty => entries.isEmpty;
}
