import 'package:bible/core/application/dtos/reading_stats.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/services/reading.repository.dart';

/// Issue du chargement des statistiques de lecture.
sealed class ReadingStatsResult {
  const ReadingStatsResult();
}

class ReadingStatsLoaded extends ReadingStatsResult {
  final ReadingStatsDto stats;

  const ReadingStatsLoaded(this.stats);
}

/// Aucun plan actif : il n'y a rien à mesurer. État nominal, comme ailleurs.
class ReadingStatsNoActivePlan extends ReadingStatsResult {
  final String message;

  const ReadingStatsNoActivePlan(this.message);
}

class ReadingStatsFailure extends ReadingStatsResult {
  final String message;

  const ReadingStatsFailure(this.message);
}

/// Charge la régularité et l'avancement sur le plan actif.
class LoadReadingStatsUseCase {
  final ReadingRepository _reading;
  final LoggerApplicationService _logger;

  const LoadReadingStatsUseCase(this._reading, this._logger);

  Future<ReadingStatsResult> execute() async {
    try {
      final stats = await _reading.loadStats();
      return ReadingStatsLoaded(ReadingStatsDto.fromDomain(stats));
    } on NoActivePlanException catch (e) {
      await _logger.info('reading.no_active_plan');
      return ReadingStatsNoActivePlan(e.message);
    } on ReadingException catch (e, stack) {
      await _logger.warn('reading.stats_failed', error: e, stack: stack);
      return ReadingStatsFailure(e.message);
    } catch (e, stack) {
      await _logger.error('reading.stats_failed', error: e, stack: stack);
      return const ReadingStatsFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
