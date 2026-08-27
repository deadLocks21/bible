import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Journalise les erreurs levées à l'intérieur des providers Riverpod.
///
/// Ni `FlutterError.onError` ni `PlatformDispatcher.onError` ne les voient :
/// Riverpod rattrape ce que lève un provider pour le ranger dans son état
/// (`AsyncError`, ou relance à la lecture). L'erreur ne traverse donc jamais la
/// zone racine. Sans cet observateur, un provider qui échoue et dont l'écran
/// n'affiche rien de particulier ne laisse **aucune trace**.
///
/// Les cas d'usage journalisent déjà leurs propres échecs, avec un libellé
/// métier autrement plus parlant : on aura donc parfois deux enregistrements
/// pour un même incident. C'est le bon compromis — `provider.failed` est le
/// filet, pas la source d'information principale, et son libellé le dit.
///
/// Enregistré sur le `ProviderContainer` construit dans `main.dart`.
final class LoggingProviderObserver extends ProviderObserver {
  /// Le logger est résolu à la demande, et non reçu à la construction :
  /// l'observateur doit exister *avant* le conteneur qui, lui seul, sait
  /// fabriquer le logger.
  final LoggerApplicationService Function() _resolveLogger;

  /// Empêche la récursion si c'est la construction du logger elle-même qui
  /// échoue : sans ce garde-fou, journaliser l'échec rappellerait le provider
  /// fautif, indéfiniment.
  bool _reporting = false;

  LoggingProviderObserver(this._resolveLogger);

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (_reporting) return;
    _reporting = true;
    try {
      _resolveLogger().error(
        'provider.failed',
        attrs: {
          // Le nom généré par `riverpod_generator` (`readingBoardProvider`…) :
          // il suffit à situer la panne dans le code, sans exposer d'état.
          'provider.name':
              context.provider.name ?? context.provider.runtimeType.toString(),
        },
        error: error,
        stack: stackTrace,
      );
    } catch (_) {
      // Un filet qui casse ne doit pas emporter l'application avec lui.
    } finally {
      _reporting = false;
    }
  }
}
