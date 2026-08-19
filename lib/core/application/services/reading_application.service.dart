import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/application/usecases/mark_entry_as_read.usecase.dart';

/// Regroupe les cas d'usage du tableau de bord de lecture.
class ReadingApplicationService {
  final LoadReadingBoardUseCase loadBoard;
  final MarkEntryAsReadUseCase markEntryAsRead;

  const ReadingApplicationService({
    required this.loadBoard,
    required this.markEntryAsRead,
  });
}
