import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/theme.repository.dart';

/// Réglages de l'application.
///
/// Le serveur visé n'en fait pas partie : il est fixé à la compilation
/// (cf. `apiBaseUrlProvider`), pas réglable par l'utilisateur.
class SettingsApplicationService {
  final ThemeRepository _themeRepository;

  const SettingsApplicationService(this._themeRepository);

  Future<AppThemeMode> getThemeMode() => _themeRepository.getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _themeRepository.setThemeMode(mode);
}
