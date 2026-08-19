import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';

/// Restaure la session persistée au démarrage, ou `null` s'il n'y en a pas.
///
/// La validité du jeton n'est pas vérifiée auprès du serveur ici : un jeton
/// Sanctum n'expire pas, et un jeton révoqué se signalera de lui-même au
/// premier appel protégé par un `401 invalid_token`, que l'intercepteur traite.
/// Interroger `GET /api/me` au démarrage ajouterait un aller-retour bloquant
/// avant le premier écran sans rien garantir de plus.
class RestoreSessionUseCase {
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const RestoreSessionUseCase(this._tokenStore, this._logger);

  Future<AuthSession?> execute() async {
    try {
      return await _tokenStore.read();
    } catch (e, stack) {
      await _logger.warn('auth.restore_failed', error: e, stack: stack);
      return null;
    }
  }
}
