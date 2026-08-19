import 'package:bible/core/application/services/reading_application.service.dart';
import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/application/usecases/mark_entry_as_read.usecase.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/reading/providers/reading.repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading.service_provider.g.dart';

@riverpod
ReadingApplicationService readingService(Ref ref) {
  final reading = ref.watch(readingRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return ReadingApplicationService(
    loadBoard: LoadReadingBoardUseCase(reading, logger),
    markEntryAsRead: MarkEntryAsReadUseCase(reading, logger),
  );
}
