import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/application/usecases/load_reading_history.usecase.dart';
import 'package:bible/core/application/usecases/load_reading_stats.usecase.dart';
import 'package:bible/core/application/usecases/mark_entry_as_read.usecase.dart';
import 'package:bible/core/application/usecases/mark_entry_as_unread.usecase.dart';

/// Regroupe les cas d'usage du tableau de bord de lecture.
class ReadingApplicationService {
  final LoadReadingBoardUseCase loadBoard;
  final MarkEntryAsReadUseCase markEntryAsRead;
  final MarkEntryAsUnreadUseCase markEntryAsUnread;
  final LoadReadingHistoryUseCase loadHistory;
  final LoadReadingStatsUseCase loadStats;

  const ReadingApplicationService({
    required this.loadBoard,
    required this.markEntryAsRead,
    required this.markEntryAsUnread,
    required this.loadHistory,
    required this.loadStats,
  });
}
