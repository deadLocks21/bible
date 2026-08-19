import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/infrastructure/auth/providers/session_revocation.provider.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.service_provider.dart';
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
  final container = ProviderContainer();
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

class _BibleAppState extends ConsumerState<BibleApp> with WidgetsBindingObserver {
  /// Permet de revenir à l'écran de connexion depuis l'extérieur de l'arbre de
  /// widgets, quand la session est révoquée alors qu'un écran est empilé.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final logger = ref.read(loggerProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        logger.info('app.resumed');
      case AppLifecycleState.paused:
        // On vide le tampon avant une éventuelle suspension par le système.
        logger.info('app.paused');
        logger.flush();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Un `401 invalid_token` sur une route protégée signifie que le jeton a été
    // révoqué ailleurs. L'intercepteur a déjà purgé le stockage local : on
    // repasse à l'écran de connexion en dépilant ce qui était ouvert.
    ref.listen(sessionRevocationProvider, (_, _) {
      ref.read(authNotifierProvider.notifier).onSessionRevoked();
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });

    return MaterialApp(
      title: 'Bible',
      navigatorKey: navigatorKey,
      theme: AppThemeData.buildLightTheme(),
      darkTheme: AppThemeData.buildDarkTheme(),
      // Le thème système s'applique tant que la préférence n'est pas lue : la
      // lecture est locale et brève, et un écran de chargement dédié pour ça
      // ferait clignoter le démarrage.
      themeMode: AppThemeData.toFlutterThemeMode(
        themeMode.value ?? AppThemeMode.system,
      ),
      home: const AuthGate(),
    );
  }
}
