import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/theme.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférence de thème persistée dans `SharedPreferences`.
class SharedPreferencesThemeRepository implements ThemeRepository {
  static const String _modeKey = 'theme_mode';
  static const String _paletteKey = 'theme_palette';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    final preferences = await _ensureInitialized();
    return AppThemeMode.fromName(preferences.getString(_modeKey));
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final preferences = await _ensureInitialized();
    await preferences.setString(_modeKey, mode.name);
  }

  @override
  Future<AppPalette> getPalette() async {
    final preferences = await _ensureInitialized();
    return AppPalette.fromName(preferences.getString(_paletteKey));
  }

  @override
  Future<void> setPalette(AppPalette palette) async {
    final preferences = await _ensureInitialized();
    await preferences.setString(_paletteKey, palette.name);
  }
}
