import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';

/// Diffuse chaque enregistrement à plusieurs [LoggerService].
///
/// Cas d'usage principal : en développement avec Signoz configuré, envelopper
/// la console et l'exportateur pour que le développeur lise dans son terminal
/// *exactement* ce qui part sur le réseau. C'est ce qui supprime l'écart entre
/// « ce que je vois en local » et « ce qui arrive dans Signoz ».
///
/// Les appels aux enfants sont séquentiels : le volume est trop faible pour que
/// le parallélisme se justifie, et l'ordre reste ainsi déterministe dans la
/// console.
///
/// Une exception levée par un enfant — ce que le contrat de [LoggerService]
/// interdit, mais on ne parie pas là-dessus — est avalée : un adaptateur
/// défaillant ne doit pas rendre les autres muets.
class CompositeLoggerService implements LoggerService {
  final List<LoggerService> _children;

  CompositeLoggerService(List<LoggerService> children)
    : assert(
        children.isNotEmpty,
        'CompositeLoggerService attend au moins un enfant',
      ),
      _children = List.unmodifiable(children);

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    for (final child in _children) {
      try {
        await child.log(
          level,
          message,
          attributes: attributes,
          error: error,
          stack: stack,
        );
      } catch (_) {
        // Voir la note de classe : on n'en fait rien de plus.
      }
    }
  }

  @override
  Future<void> flush() async {
    for (final child in _children) {
      try {
        await child.flush();
      } catch (_) {
        // Idem.
      }
    }
  }
}
