import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/core/domain/services/logger.service.dart';

/// Façade confortable au-dessus d'un [LoggerService].
///
/// Deux raisons de ne pas appeler [LoggerService] directement :
///
/// 1. **Sucre syntaxique** — `logger.info('auth.ok')` se lit mieux que
///    `logger.log(LogLevel.info, 'auth.ok')`.
/// 2. **Propagation de contexte** — chaque enregistrement est enrichi
///    d'attributs transverses, centralisés ici plutôt que répétés sur chaque
///    appel.
///
/// Les attributs sont fusionnés dans cet ordre, le plus spécifique gagnant :
/// contexte dynamique ([resolveContext], réévalué à chaque émission), contexte
/// statique ([withContext]), attributs de l'appel.
class LoggerApplicationService {
  final LoggerService _logger;
  final Map<String, Object?> _staticContext;
  final Map<String, Object?> Function()? _resolveContext;

  const LoggerApplicationService(
    this._logger, {
    Map<String, Object?> context = const {},
    Map<String, Object?> Function()? resolveContext,
  }) : _staticContext = context,
       // Un paramètre nommé ne peut pas être privé : pas de formel
       // d'initialisation possible pour ce champ.
       // ignore: prefer_initializing_formals
       _resolveContext = resolveContext;

  /// Renvoie une façade ajoutant [extra] au contexte statique courant.
  LoggerApplicationService withContext(Map<String, Object?> extra) {
    if (extra.isEmpty) return this;
    return LoggerApplicationService(
      _logger,
      context: {..._staticContext, ...extra},
      resolveContext: _resolveContext,
    );
  }

  Future<void> debug(String message, {Map<String, Object?> attrs = const {}}) =>
      _emit(LogLevel.debug, message, attrs: attrs);

  Future<void> info(String message, {Map<String, Object?> attrs = const {}}) =>
      _emit(LogLevel.info, message, attrs: attrs);

  Future<void> warn(
    String message, {
    Map<String, Object?> attrs = const {},
    Object? error,
    StackTrace? stack,
  }) => _emit(LogLevel.warn, message, attrs: attrs, error: error, stack: stack);

  Future<void> error(
    String message, {
    Map<String, Object?> attrs = const {},
    Object? error,
    StackTrace? stack,
  }) =>
      _emit(LogLevel.error, message, attrs: attrs, error: error, stack: stack);

  /// Vide le tampon du service sous-jacent, à appeler sur mise en arrière-plan.
  Future<void> flush() => _logger.flush();

  Future<void> _emit(
    LogLevel level,
    String message, {
    required Map<String, Object?> attrs,
    Object? error,
    StackTrace? stack,
  }) {
    // Une résolution de contexte qui échoue ne doit jamais faire couler un log.
    Map<String, Object?> resolved;
    try {
      resolved = _resolveContext?.call() ?? const {};
    } catch (_) {
      resolved = const {};
    }
    final merged = (resolved.isEmpty && _staticContext.isEmpty && attrs.isEmpty)
        ? const <String, Object?>{}
        : <String, Object?>{...resolved, ..._staticContext, ...attrs};
    return _logger.log(
      level,
      message,
      attributes: merged,
      error: error,
      stack: stack,
    );
  }
}
