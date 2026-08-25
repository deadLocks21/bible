import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_expanded.provider.g.dart';

/// Bandeau de régularité déplié ou replié, tel que l'utilisateur l'a laissé.
///
/// Replié par défaut : le tableau de bord existe d'abord pour la lecture du
/// jour, que le bandeau ne doit pas repousser hors de l'écran. Un réglage
/// illisible retombe sur ce même défaut plutôt que d'empêcher l'affichage.
@Riverpod(keepAlive: true)
class StatsExpandedNotifier extends _$StatsExpandedNotifier {
  @override
  Future<bool> build() async {
    try {
      return await ref.watch(settingsServiceProvider).isStatsExpanded();
    } catch (e, stack) {
      ref
          .read(loggerProvider)
          .warn('settings.stats_expanded.load_failed', error: e, stack: stack);
      return false;
    }
  }

  /// Déplie ou replie le bandeau, et retient le choix.
  Future<void> toggle() async {
    final expanded = !(state.value ?? false);
    state = AsyncData(expanded);
    try {
      await ref.read(settingsServiceProvider).setStatsExpanded(expanded);
    } catch (e, stack) {
      // L'affichage suit quand même : ne pas savoir mémoriser le choix ne doit
      // pas empêcher de l'appliquer maintenant.
      ref
          .read(loggerProvider)
          .warn('settings.stats_expanded.save_failed', error: e, stack: stack);
    }
  }
}
