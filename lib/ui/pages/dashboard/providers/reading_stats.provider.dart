import 'package:bible/core/application/dtos/reading_stats.dto.dart';
import 'package:bible/core/application/usecases/load_reading_stats.usecase.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/infrastructure/reading/providers/reading.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_stats.provider.g.dart';

/// Régularité et avancement de l'utilisateur.
///
/// Les statistiques accompagnent le tableau de bord sans le conditionner : un
/// échec de ce côté remonte en `AsyncError` et l'écran se contente de masquer
/// le bandeau, les lectures restent affichées.
@riverpod
class ReadingStatsNotifier extends _$ReadingStatsNotifier {
  @override
  Future<ReadingStatsDto?> build() => _load();

  /// Recharge les statistiques. Sans effet visible en cas d'échec : c'est un
  /// complément, pas le contenu de l'écran.
  Future<void> refresh() async {
    final stats = await _load();
    // Le bandeau n'est pas affiché en permanence — quand rien ne l'observe, le
    // provider est libéré et l'appel en vol n'a plus d'état où se poser.
    if (!ref.mounted) return;
    state = AsyncData(stats);
  }

  Future<ReadingStatsDto?> _load() async {
    final result = await ref.read(readingServiceProvider).loadStats.execute();
    return switch (result) {
      ReadingStatsLoaded(:final stats) => stats,
      // Aucun plan actif : l'historique dit déjà lequel, le bandeau s'efface.
      ReadingStatsNoActivePlan() => null,
      ReadingStatsFailure(:final message) => throw ReadingException(message),
    };
  }
}
