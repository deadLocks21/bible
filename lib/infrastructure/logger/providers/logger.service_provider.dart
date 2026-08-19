import 'dart:math';

import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/services/logger.service.dart';
import 'package:bible/infrastructure/logger/console.logger.service.dart';
import 'package:bible/infrastructure/logger/log_context.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.service_provider.g.dart';

/// Unique [LoggerService] de l'application.
///
/// La console est le seul puits pour l'instant. Le port existe justement pour
/// qu'ajouter un export distant plus tard (à la manière de kidflix et songbook)
/// ne touche que ce fichier.
@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) => const ConsoleLoggerService();

/// Contexte de log de l'application : un identifiant de session par lancement.
/// `keepAlive` pour qu'il reste stable d'un bout à l'autre de l'exécution.
@Riverpod(keepAlive: true)
LogContext logContext(Ref ref) => LogContext(sessionId: _newSessionId());

/// Façade consommée par les cas d'usage, l'UI et `main.dart`.
///
/// Le contexte dynamique lit [logContextProvider] via `ref.read` — et non
/// `ref.watch` — à chaque émission : l'instance de logger reste stable pendant
/// que chaque enregistrement porte le `session.id` courant.
@Riverpod(keepAlive: true)
LoggerApplicationService logger(Ref ref) {
  return LoggerApplicationService(
    ref.watch(loggerServiceProvider),
    resolveContext: () => ref.read(logContextProvider).toAttributes(),
  );
}

/// Identifiant de session : horodatage en base 36 suivi d'un suffixe aléatoire.
/// Il ne sert qu'à regrouper les lignes d'un même lancement, ce qui ne demande
/// ni unicité globale ni imprévisibilité.
String _newSessionId() {
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = Random().nextInt(1 << 32).toRadixString(36);
  return '$now-$suffix';
}
