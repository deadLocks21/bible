import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/infrastructure/auth/providers/session_revocation.provider.dart';
import 'package:bible/infrastructure/logger/logging.provider_observer.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:bible/ui/observability/logging.navigator_observer.dart';
import 'package:bible/ui/pages/auth/auth_gate.dart';
import 'package:bible/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:bible/ui/theme/app_theme_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Le conteneur Riverpod est construit à la main pour pouvoir lire le logger
  // avant `runApp` et brancher les gestionnaires d'erreurs ci-dessous.
  //
  // L'observateur est passé à la construction — c'est le seul moment où on
  // peut en attacher un — mais il a besoin du logger que seul ce conteneur sait
  // fabriquer : d'où la résolution paresseuse, qui n'a lieu qu'à la première
  // erreur de provider.
  late final ProviderContainer container;
  container = ProviderContainer(
    observers: [LoggingProviderObserver(() => container.read(loggerProvider))],
  );
  final logger = container.read(loggerProvider);

  _installErrorHandlers(logger);

  logger.info('app.started');

  runApp(
    UncontrolledProviderScope(container: container, child: const BibleApp()),
  );
}

/// Route vers le logger les erreurs Flutter et Dart non rattrapées.
///
/// Deux crochets couvrent la quasi-totalité des défaillances côté Dart :
///
/// - [FlutterError.onError] — erreurs synchrones du framework (build, layout,
///   rendu, assertions) ;
/// - [PlatformDispatcher.onError] — erreurs asynchrones qui échappent à tous
///   les `Future`/`Stream`/zones au-dessus d'elles.
///
/// Les plantages natifs (Swift/Obj-C, JVM) contournent les deux : ils tuent
/// l'isolat Dart avant que l'un ou l'autre ne s'exécute.
void _installErrorHandlers(LoggerApplicationService logger) {
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'flutter.error',
      error: details.exception,
      stack: details.stack,
      attrs: {
        if (details.library != null) 'flutter.library': details.library!,
        if (details.context != null)
          'flutter.context': details.context!.toString(),
      },
    );
    // On conserve le comportement par défaut (écran rouge en debug, trace dans
    // la console ailleurs) pour ne rien masquer pendant le développement.
    defaultOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('dart.uncaught', error: error, stack: stack);
    // `true` : l'erreur est considérée comme traitée, l'application continue.
    return true;
  };
}

class BibleApp extends ConsumerStatefulWidget {
  const BibleApp({super.key});

  @override
  ConsumerState<BibleApp> createState() => _BibleAppState();
}

class _BibleAppState extends ConsumerState<BibleApp>
    with WidgetsBindingObserver {
  /// Permet de revenir à l'écran de connexion depuis l'extérieur de l'arbre de
  /// widgets, quand la session est révoquée alors qu'un écran est empilé.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  late final LoggingNavigatorObserver _navigatorObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Construit une fois : `MaterialApp` compare la liste d'observateurs d'une
    // reconstruction à l'autre, et une instance neuve à chaque `build` ferait
    // désabonner puis réabonner l'observateur sans raison.
    _navigatorObserver = LoggingNavigatorObserver(ref.read(loggerProvider));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Journalise chaque transition de cycle de vie, et vide le tampon du logger
  /// avant que le système ne puisse suspendre ou tuer le processus.
  ///
  /// L'exportateur Signoz n'expédie sinon que toutes les dix secondes et ne
  /// rejoue pas un lot perdu : les dernières secondes avant la disparition du
  /// processus seraient perdues. Or c'est exactement la fenêtre qui compte —
  /// les problèmes qu'on nous rapporte finissent tous par « j'ai fermé
  /// l'application », donc par la perte de ce qui expliquait pourquoi.
  ///
  /// `app.lifecycle` sert aussi de repère à la lecture : un trou dans la
  /// chronologie devient « l'application était en arrière-plan » plutôt que
  /// « l'application était figée ».
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final logger = ref.read(loggerProvider);
    logger.info('app.lifecycle', attrs: {'app.state': state.name});
    switch (state) {
      // `hidden` et `paused` font le vrai travail : ils surviennent dès la mise
      // en arrière-plan, bien avant que l'utilisateur ne balaie l'application.
      // `detached` est au mieux-effort — la plateforme peut tuer le processus
      // avant la fin de l'envoi.
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        logger.flush();
      // Retour au premier plan : rien à forcer, la minuterie périodique reprend
      // la main et le processus n'est pas sur le point de disparaître.
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(paletteProvider);

    // Un `401 invalid_token` sur une route protégée signifie que le jeton a été
    // révoqué ailleurs. L'intercepteur a déjà purgé le stockage local : on
    // repasse à l'écran de connexion en dépilant ce qui était ouvert.
    ref.listen(sessionRevocationProvider, (_, _) {
      ref.read(loggerProvider).warn('auth.session_revoked');
      ref.read(authNotifierProvider.notifier).onSessionRevoked();
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });

    // Le `user.id` attaché à chaque log suit l'état d'authentification. Écouté
    // depuis la racine, donc renseigné quel que soit l'écran par lequel la
    // connexion s'est faite.
    ref.listen(authNotifierProvider, _onAuthStateChanged);

    return MaterialApp(
      title: 'Bible',
      navigatorKey: navigatorKey,
      // Trace la suite des écrans traversés : c'est ce qui permet de savoir, en
      // relisant une erreur dans Signoz, d'où venait l'utilisateur.
      navigatorObservers: [_navigatorObserver],
      // Les deux préférences sont indépendantes : la palette choisit les
      // couleurs, le mode choisit laquelle de ses deux ambiances s'applique.
      theme: AppThemeData.buildLightTheme(
        palette.value ?? AppThemeData.defaultPalette,
      ),
      darkTheme: AppThemeData.buildDarkTheme(
        palette.value ?? AppThemeData.defaultPalette,
      ),
      // Le thème système s'applique tant que la préférence n'est pas lue : la
      // lecture est locale et brève, et un écran de chargement dédié pour ça
      // ferait clignoter le démarrage.
      themeMode: AppThemeData.toFlutterThemeMode(
        themeMode.value ?? AppThemeMode.system,
      ),
      home: const AuthGate(),
    );
  }

  /// Tient à jour le `user.id` du contexte de log et journalise la transition.
  ///
  /// L'ordre des deux opérations n'est pas indifférent : à la connexion on
  /// renseigne avant de journaliser, à la déconnexion on journalise avant
  /// d'effacer. Dans les deux cas l'enregistrement de transition porte donc
  /// l'identifiant concerné.
  void _onAuthStateChanged(AuthState? previous, AuthState next) {
    final logger = ref.read(loggerProvider);
    final logContext = ref.read(logContextProvider);
    switch (next) {
      case AuthAuthenticated(:final user):
        logContext.userId = user.id;
        logger.info('auth.state', attrs: {'auth.state': 'authenticated'});
      case AuthUnauthenticated():
        // Une transition depuis l'initialisation n'est pas une déconnexion :
        // c'est le constat qu'aucune session n'était persistée.
        logger.info(
          'auth.state',
          attrs: {
            'auth.state': previous is AuthAuthenticated
                ? 'signed_out'
                : 'unauthenticated',
          },
        );
        logContext.userId = null;
      case AuthInitializing():
        break;
    }
  }
}
