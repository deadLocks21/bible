import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/settings.repository.dart';
import 'package:bible/core/domain/services/theme.repository.dart';

/// Réglages de l'application : thème, et URL du serveur quand l'utilisateur
/// souhaite viser autre chose que le serveur compilé dans le binaire.
class SettingsApplicationService {
  final SettingsRepository _settingsRepository;
  final ThemeRepository _themeRepository;

  const SettingsApplicationService(
    this._settingsRepository,
    this._themeRepository,
  );

  Future<String?> getBackendUrl() => _settingsRepository.getBackendUrl();

  Future<void> setBackendUrl(String url) =>
      _settingsRepository.setBackendUrl(url);

  Future<void> clearBackendUrl() => _settingsRepository.clearBackendUrl();

  Future<AppThemeMode> getThemeMode() => _themeRepository.getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _themeRepository.setThemeMode(mode);
}
