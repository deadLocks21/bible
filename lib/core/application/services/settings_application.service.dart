import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/dashboard_preferences.repository.dart';
import 'package:bible/core/domain/services/theme.repository.dart';

/// Réglages de l'application.
///
/// Le serveur visé n'en fait pas partie : il est fixé à la compilation
/// (cf. `apiBaseUrlProvider`), pas réglable par l'utilisateur.
class SettingsApplicationService {
  final ThemeRepository _themeRepository;
  final DashboardPreferencesRepository _dashboardPreferences;

  const SettingsApplicationService(
    this._themeRepository,
    this._dashboardPreferences,
  );

  Future<AppThemeMode> getThemeMode() => _themeRepository.getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _themeRepository.setThemeMode(mode);

  Future<AppPalette> getPalette() => _themeRepository.getPalette();

  Future<void> setPalette(AppPalette palette) =>
      _themeRepository.setPalette(palette);

  /// Bandeau de régularité déplié sur le tableau de bord. Replié par défaut.
  Future<bool> isStatsExpanded() => _dashboardPreferences.isStatsExpanded();

  Future<void> setStatsExpanded(bool expanded) =>
      _dashboardPreferences.setStatsExpanded(expanded);
}
