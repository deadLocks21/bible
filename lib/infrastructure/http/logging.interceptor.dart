import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:dio/dio.dart';

/// Journalise un enregistrement par appel HTTP, avec sa durée mesurée côté
/// client.
///
/// C'est la trace la plus utile quand « l'application ne marche pas » : elle
/// dit si la requête est partie, ce que le serveur a répondu, en combien de
/// temps, et sous quel code d'erreur métier. Les logs de l'API racontent le
/// reste ; l'écart entre les deux durées, lui, ne se lit que d'ici (DNS, TLS,
/// latence montante, transfert, décodage).
///
/// Niveaux retenus :
///
/// | Situation                            | Niveau | Message      |
/// |--------------------------------------|--------|--------------|
/// | 2xx/3xx                              | debug  | `http.call`  |
/// | 4xx                                  | warn   | `http.failed`|
/// | 5xx, délai dépassé, serveur injoignable | error | `http.failed`|
/// | requête annulée                      | debug  | `http.call`  |
///
/// Un 4xx reste un `warn` : `401 invalid_credentials` ou `409 already_read`
/// sont des réponses nominales de l'API à une saisie ou à un enchaînement
/// d'écrans, pas des pannes. Un 5xx ou un serveur muet, si.
///
/// **Ce qui n'est jamais journalisé** : le corps des requêtes et des réponses,
/// et les en-têtes. Les formulaires de connexion, d'inscription et de
/// changement de mot de passe y font passer des mots de passe en clair, et
/// l'en-tête `Authorization` porte le jeton de session. Seuls la méthode, le
/// chemin, le statut, la durée et le `code` machine de l'API sortent d'ici.
class LoggingInterceptor extends Interceptor {
  final LoggerApplicationService _logger;

  LoggingInterceptor(this._logger);

  /// Clé du chronomètre déposé dans `options.extra`. Préfixée pour ne pas
  /// entrer en collision avec les `extra` d'un autre intercepteur.
  static const String _startKey = 'bible.http.stopwatch';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // Sans `await` : instrumenter un appel ne doit ni le ralentir ni le faire
    // échouer. Le logger met en tampon, l'envoi part de son côté.
    _logger.debug(
      'http.call',
      attrs: _attributes(
        options: response.requestOptions,
        status: response.statusCode,
      ),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final attrs = _attributes(
      options: err.requestOptions,
      status: status,
      // Le type Dio distingue `connectionTimeout` de `connectionError` ou de
      // `badCertificate` : c'est ce qui différencie « le serveur est lent » de
      // « le serveur est injoignable ».
      dioType: err.type.name,
      apiCode: _apiCodeOf(err.response?.data),
    );

    if (err.type == DioExceptionType.cancel) {
      // Un écran quitté pendant son chargement annule sa requête : c'est du
      // fonctionnement normal, pas une panne.
      _logger.debug('http.call', attrs: attrs);
    } else if (status != null && status < 500) {
      _logger.warn('http.failed', attrs: attrs);
    } else {
      // Pas de `error:`/`stack:` : la `DioException` ne dit rien de plus que
      // les attributs ci-dessus, et sa pile d'appels est celle des entrailles
      // de Dio, pas celle de l'appelant.
      _logger.error('http.failed', attrs: attrs);
    }

    handler.next(err);
  }

  Map<String, Object?> _attributes({
    required RequestOptions options,
    required int? status,
    String? dioType,
    String? apiCode,
  }) {
    final stopwatch = options.extra[_startKey];
    return {
      'http.method': options.method,
      // Le chemin seul : les paramètres de requête ne portent ici qu'un numéro
      // de page, et la règle « pas de données de requête dans les logs » vaut
      // mieux d'être tenue sans exception.
      'http.path': options.uri.path,
      'http.status': ?status,
      if (stopwatch is Stopwatch)
        'duration_ms': (stopwatch..stop()).elapsedMilliseconds,
      'http.error_type': ?dioType,
      'api.code': ?apiCode,
    };
  }

  /// `code` machine de la réponse d'erreur de l'API (`invalid_credentials`,
  /// `no_active_plan`…), quand elle en porte un. C'est lui — jamais le message
  /// destiné à l'utilisateur — qui permet de compter les occurrences d'un même
  /// problème dans Signoz.
  String? _apiCodeOf(Object? data) {
    if (data is! Map) return null;
    final code = data['code'];
    return code is String ? code : null;
  }
}
