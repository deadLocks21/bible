import 'package:bible/core/domain/model/app_theme_mode.dart';

/// Stockage de la préférence de thème.
abstract interface class ThemeRepository {
  Future<AppThemeMode> getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode);
}
