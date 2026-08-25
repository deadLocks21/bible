import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/services/reading.repository.dart';

/// Repasse une lecture en non lue et renvoie le tableau de bord rafraîchi.
///
/// Comme pour le marquage, l'API répond avec le nouvel état : l'écran n'a pas à
/// enchaîner un rechargement.
class MarkEntryAsUnreadUseCase {
  final ReadingRepository _reading;
  final LoggerApplicationService _logger;

  const MarkEntryAsUnreadUseCase(this._reading, this._logger);

  Future<ReadingBoardResult> execute(String entryId) async {
    try {
      final board = await _reading.markAsUnread(entryId);
      await _logger.info('reading.entry_unread');
      return ReadingBoardLoaded(ReadingBoardDto.fromDomain(board));
    } on NoActivePlanException catch (e) {
      await _logger.info('reading.no_active_plan');
      return ReadingBoardNoActivePlan(e.message);
    } on ReadingException catch (e, stack) {
      await _logger.warn('reading.mark_unread_failed', error: e, stack: stack);
      return ReadingBoardFailure(e.message);
    } catch (e, stack) {
      await _logger.error('reading.mark_unread_failed', error: e, stack: stack);
      return const ReadingBoardFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
