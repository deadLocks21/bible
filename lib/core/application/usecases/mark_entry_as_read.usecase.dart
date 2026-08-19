import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/services/reading.repository.dart';

/// Marque une lecture comme lue et renvoie le tableau de bord rafraîchi.
///
/// L'API répond directement avec le nouvel état : il n'y a donc pas de
/// rechargement à enchaîner, et pas de fenêtre pendant laquelle l'écran
/// afficherait une lecture déjà validée.
class MarkEntryAsReadUseCase {
  final ReadingRepository _reading;
  final LoggerApplicationService _logger;

  const MarkEntryAsReadUseCase(this._reading, this._logger);

  Future<ReadingBoardResult> execute(String entryId) async {
    try {
      final board = await _reading.markAsRead(entryId);
      await _logger.info('reading.entry_read');
      return ReadingBoardLoaded(ReadingBoardDto.fromDomain(board));
    } on NoActivePlanException catch (e) {
      await _logger.info('reading.no_active_plan');
      return ReadingBoardNoActivePlan(e.message);
    } on ReadingException catch (e, stack) {
      await _logger.warn('reading.mark_read_failed', error: e, stack: stack);
      return ReadingBoardFailure(e.message);
    } catch (e, stack) {
      await _logger.error('reading.mark_read_failed', error: e, stack: stack);
      return const ReadingBoardFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
