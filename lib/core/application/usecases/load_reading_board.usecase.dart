import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/services/reading.repository.dart';

/// Issue du chargement du tableau de bord, partagée avec
/// [MarkEntryAsReadUseCase] : les deux appels renvoient le même état.
sealed class ReadingBoardResult {
  const ReadingBoardResult();
}

class ReadingBoardLoaded extends ReadingBoardResult {
  final ReadingBoardDto board;

  const ReadingBoardLoaded(this.board);
}

/// Aucun plan actif n'est assigné. État nominal, pas une panne : l'assignation
/// se fait côté serveur, l'écran l'explique plutôt que d'inviter à réessayer.
class ReadingBoardNoActivePlan extends ReadingBoardResult {
  final String message;

  const ReadingBoardNoActivePlan(this.message);
}

class ReadingBoardFailure extends ReadingBoardResult {
  final String message;

  const ReadingBoardFailure(this.message);
}

/// Charge le plan actif et ses prochaines lectures.
class LoadReadingBoardUseCase {
  final ReadingRepository _reading;
  final LoggerApplicationService _logger;

  const LoadReadingBoardUseCase(this._reading, this._logger);

  Future<ReadingBoardResult> execute() async {
    try {
      final board = await _reading.loadBoard();
      return ReadingBoardLoaded(ReadingBoardDto.fromDomain(board));
    } on NoActivePlanException catch (e) {
      await _logger.info('reading.no_active_plan');
      return ReadingBoardNoActivePlan(e.message);
    } on ReadingException catch (e, stack) {
      await _logger.warn('reading.load_failed', error: e, stack: stack);
      return ReadingBoardFailure(e.message);
    } catch (e, stack) {
      await _logger.error('reading.load_failed', error: e, stack: stack);
      return const ReadingBoardFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
