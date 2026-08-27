// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(loggerService)
final loggerServiceProvider = LoggerServiceProvider._();

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

final class LoggerServiceProvider
    extends $FunctionalProvider<LoggerService, LoggerService, LoggerService>
    with $Provider<LoggerService> {
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
  LoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerServiceHash();

  @$internal
  @override
  $ProviderElement<LoggerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerService create(Ref ref) {
    return loggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerService>(value),
    );
  }
}

String _$loggerServiceHash() => r'ceda60f2947586d3693bc90cbd011188ff1796ae';

/// Contexte de log de l'application : un identifiant de session par lancement,
/// et l'identifiant du compte une fois connecté. `keepAlive` pour qu'il reste
/// stable d'un bout à l'autre de l'exécution.

@ProviderFor(logContext)
final logContextProvider = LogContextProvider._();

/// Contexte de log de l'application : un identifiant de session par lancement,
/// et l'identifiant du compte une fois connecté. `keepAlive` pour qu'il reste
/// stable d'un bout à l'autre de l'exécution.

final class LogContextProvider
    extends $FunctionalProvider<LogContext, LogContext, LogContext>
    with $Provider<LogContext> {
  /// Contexte de log de l'application : un identifiant de session par lancement,
  /// et l'identifiant du compte une fois connecté. `keepAlive` pour qu'il reste
  /// stable d'un bout à l'autre de l'exécution.
  LogContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logContextHash();

  @$internal
  @override
  $ProviderElement<LogContext> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogContext create(Ref ref) {
    return logContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogContext value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogContext>(value),
    );
  }
}

String _$logContextHash() => r'7916b30d4efa4e429461a7c504455c3530e1b103';

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

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

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

final class LoggerProvider
    extends
        $FunctionalProvider<
          LoggerApplicationService,
          LoggerApplicationService,
          LoggerApplicationService
        >
    with $Provider<LoggerApplicationService> {
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
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<LoggerApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoggerApplicationService create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerApplicationService>(value),
    );
  }
}

String _$loggerHash() => r'67ee01fc07a27c9ee89ef2e3a8fbbc49c5ff4a12';
