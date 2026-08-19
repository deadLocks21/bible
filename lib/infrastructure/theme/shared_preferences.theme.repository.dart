import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/theme.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférence de thème persistée dans `SharedPreferences`.
class SharedPreferencesThemeRepository implements ThemeRepository {
  static const String _key = 'theme_mode';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    final preferences = await _ensureInitialized();
    return AppThemeMode.fromName(preferences.getString(_key));
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final preferences = await _ensureInitialized();
    await preferences.setString(_key, mode.name);
  }
}
