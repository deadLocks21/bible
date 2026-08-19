import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/infrastructure/auth/in_memory.auth_token_store.dart';
import 'package:bible/infrastructure/auth/shared_preferences.auth_token_store.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_store.provider.g.dart';

/// Stockage de la session : `SharedPreferences` hors web, en mémoire sur le web.
///
/// `keepAlive` : une seule instance partagée entre les cas d'usage
/// d'authentification (écriture) et l'intercepteur Dio (lecture du jeton), pour
/// que le cache mémoire reste cohérent des deux côtés.
@Riverpod(keepAlive: true)
AuthTokenStore authTokenStore(Ref ref) {
  if (kIsWeb) {
    return InMemoryAuthTokenStore();
  }
  return SharedPreferencesAuthTokenStore(ref.watch(loggerProvider));
}
