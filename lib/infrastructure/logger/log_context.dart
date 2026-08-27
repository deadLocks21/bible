/// Attributs d'identité transverses attachés à chaque enregistrement de log via
/// le résolveur dynamique de `LoggerApplicationService`.
///
/// Porté par un unique provider `keepAlive`, il reste donc stable d'un bout à
/// l'autre de l'exécution :
///
/// - [sessionId] est fixé à la construction — une valeur par lancement — de
///   sorte qu'une exécution complète se reconstitue en filtrant sur
///   `session.id` ;
/// - [userId] est nul tant que personne n'est connecté, puis renseigné à la
///   restauration de session, à la connexion et à l'inscription, et remis à nul
///   à la déconnexion. C'est ce qui permet de relier plusieurs lancements au
///   même compte quand quelqu'un signale un problème.
///
/// L'adresse e-mail et le nom ne sont volontairement pas journalisés :
/// l'identifiant numérique suffit à retrouver le compte côté API, sans faire
/// voyager de donnée personnelle jusqu'à Signoz.
class LogContext {
  final String sessionId;
  int? userId;

  LogContext({required this.sessionId, this.userId});

  Map<String, Object?> toAttributes() => {
    'session.id': sessionId,
    if (userId != null) 'user.id': userId,
  };
}
