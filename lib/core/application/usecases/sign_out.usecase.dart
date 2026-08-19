import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';

/// Déconnexion : révocation du jeton côté serveur puis effacement local.
///
/// L'effacement local est inconditionnel. Si l'appel de révocation échoue
/// (serveur injoignable, jeton déjà révoqué), l'utilisateur doit tout de même
/// se retrouver déconnecté sur son appareil — sinon un incident réseau le
/// bloquerait dans une session dont il veut sortir.
class SignOutUseCase {
  final AuthRepository _auth;
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const SignOutUseCase(this._auth, this._tokenStore, this._logger);

  Future<void> execute() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      await _logger.warn('auth.sign_out_remote_failed', error: e, stack: stack);
    }
    try {
      await _tokenStore.clear();
    } catch (e, stack) {
      await _logger.warn('auth.sign_out_clear_failed', error: e, stack: stack);
    }
    await _logger.info('auth.signed_out');
  }
}
