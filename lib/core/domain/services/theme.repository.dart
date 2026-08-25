import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';

/// Stockage des préférences de thème : le jeu de couleurs et l'ambiance.
///
/// Les deux sont indépendants — chaque palette existe en clair comme en
/// sombre — d'où deux préférences distinctes.
abstract interface class ThemeRepository {
  Future<AppThemeMode> getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode);

  Future<AppPalette> getPalette();

  Future<void> setPalette(AppPalette palette);
}
