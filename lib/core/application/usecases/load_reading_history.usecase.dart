import 'package:bible/core/application/dtos/reading_history.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/services/reading.repository.dart';

/// Issue du chargement d'une page d'historique.
sealed class ReadingHistoryResult {
  const ReadingHistoryResult();
}

class ReadingHistoryLoaded extends ReadingHistoryResult {
  final ReadingHistoryDto history;

  const ReadingHistoryLoaded(this.history);
}

/// Aucun plan actif : l'historique n'a rien à montrer. État nominal, pas une
/// panne — comme sur le tableau de bord.
class ReadingHistoryNoActivePlan extends ReadingHistoryResult {
  final String message;

  const ReadingHistoryNoActivePlan(this.message);
}

class ReadingHistoryFailure extends ReadingHistoryResult {
  final String message;

  const ReadingHistoryFailure(this.message);
}

/// Charge une page de l'historique de lecture.
class LoadReadingHistoryUseCase {
  final ReadingRepository _reading;
  final LoggerApplicationService _logger;

  const LoadReadingHistoryUseCase(this._reading, this._logger);

  Future<ReadingHistoryResult> execute({int page = 1}) async {
    try {
      final history = await _reading.loadHistory(page: page);
      return ReadingHistoryLoaded(ReadingHistoryDto.fromDomain(history));
    } on NoActivePlanException catch (e) {
      await _logger.info('reading.no_active_plan');
      return ReadingHistoryNoActivePlan(e.message);
    } on ReadingException catch (e, stack) {
      await _logger.warn('reading.history_failed', error: e, stack: stack);
      return ReadingHistoryFailure(e.message);
    } catch (e, stack) {
      await _logger.error('reading.history_failed', error: e, stack: stack);
      return const ReadingHistoryFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
