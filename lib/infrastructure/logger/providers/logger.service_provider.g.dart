// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Unique [LoggerService] de l'application.
///
/// La console est le seul puits pour l'instant. Le port existe justement pour
/// qu'ajouter un export distant plus tard (à la manière de kidflix et songbook)
/// ne touche que ce fichier.

@ProviderFor(loggerService)
final loggerServiceProvider = LoggerServiceProvider._();

/// Unique [LoggerService] de l'application.
///
/// La console est le seul puits pour l'instant. Le port existe justement pour
/// qu'ajouter un export distant plus tard (à la manière de kidflix et songbook)
/// ne touche que ce fichier.

final class LoggerServiceProvider
    extends $FunctionalProvider<LoggerService, LoggerService, LoggerService>
    with $Provider<LoggerService> {
  /// Unique [LoggerService] de l'application.
  ///
  /// La console est le seul puits pour l'instant. Le port existe justement pour
  /// qu'ajouter un export distant plus tard (à la manière de kidflix et songbook)
  /// ne touche que ce fichier.
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

String _$loggerServiceHash() => r'f8676e39a0224a2b7e2b63cfc598a5440878b7c3';

/// Contexte de log de l'application : un identifiant de session par lancement.
/// `keepAlive` pour qu'il reste stable d'un bout à l'autre de l'exécution.

@ProviderFor(logContext)
final logContextProvider = LogContextProvider._();

/// Contexte de log de l'application : un identifiant de session par lancement.
/// `keepAlive` pour qu'il reste stable d'un bout à l'autre de l'exécution.

final class LogContextProvider
    extends $FunctionalProvider<LogContext, LogContext, LogContext>
    with $Provider<LogContext> {
  /// Contexte de log de l'application : un identifiant de session par lancement.
  /// `keepAlive` pour qu'il reste stable d'un bout à l'autre de l'exécution.
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
/// que chaque enregistrement porte le `session.id` courant.

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// Façade consommée par les cas d'usage, l'UI et `main.dart`.
///
/// Le contexte dynamique lit [logContextProvider] via `ref.read` — et non
/// `ref.watch` — à chaque émission : l'instance de logger reste stable pendant
/// que chaque enregistrement porte le `session.id` courant.

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
  /// que chaque enregistrement porte le `session.id` courant.
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
