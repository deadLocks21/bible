import 'package:bible/core/domain/services/settings.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages persistés dans `SharedPreferences`.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _backendUrlKey = 'backend_url';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getBackendUrl() async {
    final preferences = await _ensureInitialized();
    return preferences.getString(_backendUrlKey);
  }

  @override
  Future<void> setBackendUrl(String url) async {
    final preferences = await _ensureInitialized();
    await preferences.setString(_backendUrlKey, url);
  }

  @override
  Future<void> clearBackendUrl() async {
    final preferences = await _ensureInitialized();
    await preferences.remove(_backendUrlKey);
  }
}
