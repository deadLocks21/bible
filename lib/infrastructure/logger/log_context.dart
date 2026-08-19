/// Attributs d'identité transverses attachés à chaque enregistrement de log via
/// le résolveur dynamique de `LoggerApplicationService`.
///
/// [sessionId] est fixé à la construction — une valeur par lancement — de sorte
/// qu'une exécution complète se reconstitue en filtrant sur `session.id`.
class LogContext {
  final String sessionId;

  LogContext({required this.sessionId});

  Map<String, Object?> toAttributes() => {'session.id': sessionId};
}
