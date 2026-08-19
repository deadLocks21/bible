import 'package:bible/core/domain/model/log_level.dart';

/// Port de journalisation.
///
/// Contrat volontairement minimal — un unique puits asynchrone. Le confort
/// d'appel (`info`, `error`, attributs de contexte automatiques) vit dans la
/// couche application (`LoggerApplicationService`) pour que le port reste
/// stable quand on change d'adaptateur.
///
/// Les implémentations vivent dans `lib/infrastructure/logger/` :
///
/// - `ConsoleLoggerService`  — écrit dans la console de développement ;
/// - `InMemoryLoggerService` — capture les enregistrements pour les tests.
///
/// Une implémentation ne doit **jamais** lever : un logger défaillant dégrade
/// en silence, il ne fait pas tomber l'application.
abstract interface class LoggerService {
  /// Enregistre une entrée.
  ///
  /// [message] est un libellé court et stable (`auth.failed`, pas
  /// « Connexion impossible pour jean@… à 10h42 ») ; les données variables
  /// vont dans [attributes].
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes,
    Object? error,
    StackTrace? stack,
  });

  /// Vide un éventuel tampon. Sans effet pour les adaptateurs qui n'en ont pas.
  Future<void> flush();
}
