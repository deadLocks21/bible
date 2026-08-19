import 'dart:convert';

import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/model/user.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste la session dans `SharedPreferences`, comme les autres réglages.
/// Le stockage n'est pas chiffré, mais il évite les problèmes d'entitlement
/// Keychain sur macOS et reste cloisonné par application.
///
/// Un cache mémoire évite de relire le stockage à chaque requête HTTP : la
/// valeur est lue une fois, puis réutilisée jusqu'à la prochaine écriture ou
/// au prochain effacement.
///
/// Le [LoggerApplicationService] optionnel sert à diagnostiquer les
/// déconnexions silencieuses : au démarrage, on veut distinguer « clé absente »
/// (jamais connecté, ou session disparue du stockage sans `clear()` — typiquement
/// une restauration de sauvegarde) de « clé présente mais illisible ». Le jeton
/// lui-même n'est jamais journalisé, seulement des métadonnées.
class SharedPreferencesAuthTokenStore implements AuthTokenStore {
  static const String _key = 'auth_session';

  final LoggerApplicationService? _logger;

  SharedPreferences? _preferences;
  AuthSession? _cached;
  bool _loaded = false;

  SharedPreferencesAuthTokenStore([this._logger]);

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AuthSession?> read() async {
    if (_loaded) return _cached;

    SharedPreferences preferences;
    try {
      preferences = await _ensureInitialized();
    } catch (e, stack) {
      // Stockage indisponible : on dégrade en « pas de session ».
      _logger?.warn('auth.token.read_unavailable', error: e, stack: stack);
      _cached = null;
      _loaded = true;
      return _cached;
    }

    final raw = preferences.getString(_key);
    if (raw == null) {
      _logger?.info(
        'auth.token.absent',
        attrs: {'prefs.keys': _presentKeys(preferences)},
      );
      _cached = null;
      _loaded = true;
      return _cached;
    }

    try {
      _cached = _decode(raw);
    } catch (e, stack) {
      // Valeur présente mais illisible. `raw` n'est jamais journalisé (il porte
      // le jeton) — seulement sa taille, pour distinguer une troncature d'un
      // format inattendu.
      _logger?.warn(
        'auth.token.corrupt',
        attrs: {
          'prefs.keys': _presentKeys(preferences),
          'raw.length': raw.length,
        },
        error: e,
        stack: stack,
      );
      _cached = null;
    }
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(AuthSession session) async {
    _cached = session;
    _loaded = true;
    final preferences = await _ensureInitialized();
    await preferences.setString(_key, _encode(session));
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    final preferences = await _ensureInitialized();
    await preferences.remove(_key);
    // Trace explicite que c'est l'application qui a retiré la session, par
    // opposition à une disparition externe — où l'on verrait `auth.token.absent`
    // au démarrage suivant sans `auth.token.cleared` avant.
    _logger?.info('auth.token.cleared');
  }

  /// Noms — jamais les valeurs — des clés présentes, triés, pour distinguer
  /// « tout le fichier de préférences a sauté » de « seule la session a sauté ».
  String _presentKeys(SharedPreferences preferences) =>
      (preferences.getKeys().toList()..sort()).join(',');

  String _encode(AuthSession session) => jsonEncode({
    'token': session.token,
    'user': {
      'id': session.user.id,
      'name': session.user.name,
      'email': session.user.email,
    },
  });

  AuthSession _decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    return AuthSession(
      token: json['token'] as String,
      user: User(
        id: user['id'] as int,
        name: user['name'] as String? ?? '',
        email: user['email'] as String? ?? '',
      ),
    );
  }
}
