import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/core/utils/backend_endpoints.dart';
import 'package:dio/dio.dart';

/// Ajoute `Authorization: Bearer <jeton>` aux routes protégées, et purge la
/// session locale quand l'API répond `401 invalid_token`.
///
/// Un jeton Sanctum n'expire pas : il devient invalide parce qu'il a été
/// révoqué ailleurs (déconnexion depuis un autre appareil, changement de mot de
/// passe, suppression du compte). Le `401` est donc le seul signal fiable, et
/// c'est lui qui déclenche le retour à l'écran de connexion via
/// [onUnauthorized].
class AuthInterceptor extends Interceptor {
  final AuthTokenStore _tokenStore;
  final void Function() _onUnauthorized;
  final LoggerApplicationService _logger;

  AuthInterceptor(this._tokenStore, this._onUnauthorized, this._logger);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Connexion et inscription sont publiques ; la déconnexion, elle, doit
    // porter le jeton qu'elle révoque.
    if (!BackendEndpoints.isPublic(options.uri.path)) {
      final session = await _tokenStore.read();
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.token}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    final code = data is Map ? data['code'] : null;
    if (err.response?.statusCode == 401 &&
        code == 'invalid_token' &&
        !BackendEndpoints.isPublic(err.requestOptions.uri.path)) {
      await _logger.warn(
        'auth.token.revoked_401',
        attrs: {'request.path': err.requestOptions.uri.path},
      );
      await _tokenStore.clear();
      _onUnauthorized();
    }
    // L'erreur continue son chemin : le repository appelant la traduit en
    // exception de domaine, la révocation se joue à côté.
    handler.next(err);
  }
}
