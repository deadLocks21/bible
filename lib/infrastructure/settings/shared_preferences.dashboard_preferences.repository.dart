import 'package:bible/core/domain/services/dashboard_preferences.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférences du tableau de bord persistées dans `SharedPreferences`, comme
/// celle du thème.
class SharedPreferencesDashboardPreferencesRepository
    implements DashboardPreferencesRepository {
  static const String _statsExpandedKey = 'dashboard_stats_expanded';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> isStatsExpanded() async {
    final preferences = await _ensureInitialized();
    // Absent du stockage : replié, l'état par défaut.
    return preferences.getBool(_statsExpandedKey) ?? false;
  }

  @override
  Future<void> setStatsExpanded(bool expanded) async {
    final preferences = await _ensureInitialized();
    await preferences.setBool(_statsExpandedKey, expanded);
  }
}
