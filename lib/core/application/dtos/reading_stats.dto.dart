import 'package:bible/core/domain/model/reading_stats.dart';

/// Projection des statistiques de lecture pour l'UI.
class ReadingStatsDto {
  final int currentStreak;
  final int longestStreak;
  final int readCount;
  final int planEntryCount;
  final DateTime? firstReadAt;

  /// Avancement dans le plan, entre 0 et 1.
  final double progress;

  const ReadingStatsDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.readCount,
    required this.planEntryCount,
    required this.firstReadAt,
    required this.progress,
  });

  factory ReadingStatsDto.fromDomain(ReadingStats stats) => ReadingStatsDto(
    currentStreak: stats.currentStreak,
    longestStreak: stats.longestStreak,
    readCount: stats.readCount,
    planEntryCount: stats.planEntryCount,
    firstReadAt: stats.firstReadAt,
    progress: stats.progress,
  );

  /// Avancement en pourcentage entier, prêt à afficher.
  int get progressPercent => (progress * 100).round();

  bool get isEmpty => readCount == 0;
}
