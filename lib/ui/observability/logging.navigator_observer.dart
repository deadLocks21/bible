import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:flutter/material.dart';

/// Journalise les changements d'écran.
///
/// Sans cette trace, un log d'erreur ne dit pas *où* l'utilisateur se trouvait
/// quand ça a cassé : c'est pourtant la première question qu'on se pose en
/// lisant Signoz. Avec elle, filtrer sur une `session.id` donne la suite des
/// écrans traversés jusqu'à l'erreur.
///
/// Ne journalise que les routes **nommées** (`RouteSettings(name: …)`, cf.
/// [AppRoutes]). Les routes anonymes sont les boîtes de dialogue et les feuilles
/// modales : les nommer une à une n'apprendrait rien de plus que l'action métier
/// déjà journalisée par le cas d'usage correspondant.
class LoggingNavigatorObserver extends NavigatorObserver {
  final LoggerApplicationService _logger;

  LoggingNavigatorObserver(this._logger);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // `previousRoute` est l'écran qui redevient visible : c'est lui qui compte
    // pour savoir où l'on retombe.
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('replace', newRoute, oldRoute);
  }

  void _log(String action, Route<dynamic>? route, Route<dynamic>? previous) {
    final name = _nameOf(route);
    if (name == null) return;
    final from = _nameOf(previous);
    // Sans `await` : la navigation ne doit pas attendre la journalisation.
    _logger.info(
      'ui.screen',
      attrs: {
        'ui.action': action,
        'ui.screen': name,
        'ui.from': ?from,
      },
    );
  }

  /// Nom lisible d'une route. La route initiale, créée par `MaterialApp` à
  /// partir de son `home:`, s'appelle `/` : on la renomme pour qu'un tableau de
  /// bord n'ait pas à connaître cette convention de Flutter.
  String? _nameOf(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return null;
    return name == '/' ? AppRoutes.home : name;
  }
}

/// Noms des écrans, tels qu'ils apparaissent dans `ui.screen`.
///
/// Rassemblés ici pour qu'ils restent stables : un nom d'écran qui change au
/// fil des refontes rend inexploitable tout tableau de bord qui s'appuie
/// dessus.
abstract final class AppRoutes {
  static const String home = 'home';
  static const String login = 'login';
  static const String register = 'register';
  static const String dashboard = 'dashboard';
  static const String history = 'history';
  static const String settings = 'settings';

  /// Réglages d'écran, à passer à `MaterialPageRoute(settings: …)`.
  static RouteSettings of(String name) => RouteSettings(name: name);
}
