import 'dart:math';

import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/services/logger.service.dart';
import 'package:bible/infrastructure/logger/composite.logger.service.dart';
import 'package:bible/infrastructure/logger/console.logger.service.dart';
import 'package:bible/infrastructure/logger/log_context.dart';
import 'package:bible/infrastructure/logger/signoz.logger.service.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, kReleaseMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.service_provider.g.dart';

/// Point d'entrée OTLP HTTP de Signoz, fixé à la compilation. Vide → aucun
/// export, l'application se contente de sa console.
///
/// ```sh
/// flutter run --dart-define=SIGNOZ_INGEST_URL=https://signoz.example.org:4318/v1/logs
/// ```
///
/// En release, la CI l'injecte depuis le secret GitHub du même nom (cf.
/// `.github/workflows/release.yml`).
const String _kSignozEndpoint = String.fromEnvironment('SIGNOZ_INGEST_URL');

/// Jeton d'ingestion Signoz, envoyé en en-tête `signoz-access-token`. Laisser
/// vide pour une instance auto-hébergée sans authentification.
const String _kSignozKey = String.fromEnvironment('SIGNOZ_INGESTION_KEY');

/// Remplace la valeur de l'attribut de ressource `deployment.environment`.
/// À défaut : `production` en release, `development` sinon.
const String _kEnvOverride = String.fromEnvironment('SIGNOZ_ENV');

/// Version publiée en attribut de ressource `service.version`, injectée par la
/// CI (`--dart-define=APP_VERSION=$VERSION+$RUN_NUMBER`). La valeur par défaut
/// rend visible dans Signoz un binaire compilé à la main.
const String _kAppVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: 'dev',
);

/// Unique [LoggerService] de l'application.
///
/// Le choix de l'implémentation :
///
/// | Mode    | `SIGNOZ_INGEST_URL` | Implémentation                          |
/// |---------|---------------------|-----------------------------------------|
/// | release | absent              | console seule (repli sûr)               |
/// | release | présent             | Signoz seul                             |
/// | debug   | absent              | console seule                           |
/// | debug   | présent             | composite : console + Signoz            |
///
/// La dernière ligne est celle qui permet de vérifier un branchement : le
/// développeur lit dans son terminal, préfixé `[→signoz]`, exactement ce qui
/// part sur le réseau.
///
/// `keepAlive` parce que l'adaptateur Signoz détient une minuterie et un client
/// HTTP qu'il serait absurde de reconstruire à la demande — et parce qu'une
/// reconstruction jetterait le tampon d'envoi en cours.
@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) {
  final hasSignoz = _kSignozEndpoint.trim().isNotEmpty;

  final console = ConsoleLoggerService(
    prefix: hasSignoz && !kReleaseMode ? '[→signoz]' : null,
  );

  if (!hasSignoz) return console;

  final signoz = SignozLoggerService(
    endpoint: _kSignozEndpoint,
    ingestionKey: _kSignozKey.isEmpty ? null : _kSignozKey,
    resourceAttributes: _resourceAttributes(),
  );
  ref.onDispose(signoz.dispose);

  if (kReleaseMode) return signoz;
  return CompositeLoggerService([console, signoz]);
}

/// Contexte de log de l'application : un identifiant de session par lancement,
/// et l'identifiant du compte une fois connecté. `keepAlive` pour qu'il reste
/// stable d'un bout à l'autre de l'exécution.
@Riverpod(keepAlive: true)
LogContext logContext(Ref ref) => LogContext(sessionId: _newSessionId());

/// Façade consommée par les cas d'usage, l'UI et `main.dart`.
///
/// Le contexte dynamique lit [logContextProvider] via `ref.read` — et non
/// `ref.watch` — à chaque émission : l'instance de logger reste stable pendant
/// que chaque enregistrement porte le `session.id` et le `user.id` courants.
/// La reconstruire à chaque connexion viderait le tampon d'envoi de Signoz.
///
/// `service.version`, `os.type` et `deployment.environment` ne sont pas ici :
/// ils sont attachés une fois par lot, en attributs de *ressource* OTLP (cf.
/// [loggerService]).
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

Map<String, Object?> _resourceAttributes() {
  final environment = _kEnvOverride.isNotEmpty
      ? _kEnvOverride
      : (kReleaseMode ? 'production' : 'development');
  return {
    'service.name': 'bible',
    'service.version': _kAppVersion,
    'deployment.environment': environment,
    'os.type': _osType(),
    // Signoz range ses logs par hôte et par conteneur dans plusieurs de ses
    // vues ; sans ces deux valeurs, une application mobile y apparaît sous un
    // hôte vide, indistinguable des autres.
    'container.name': 'bible-flutter',
    'host.name': 'fr.dtfh.bible',
  };
}

/// Système d'exploitation, déduit de [defaultTargetPlatform] plutôt que de
/// `Platform.operatingSystem` : `dart:io` ne compile pas pour le web, et la
/// cible web existe dans ce dépôt.
String _osType() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.linux => 'linux',
    TargetPlatform.windows => 'windows',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}
