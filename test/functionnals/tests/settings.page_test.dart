import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/services/settings.repository.dart';
import 'package:bible/core/domain/services/theme.repository.dart';
import 'package:bible/infrastructure/http/providers/api_base_url.provider.dart';
import 'package:bible/infrastructure/settings/providers/settings.repository_provider.dart';
import 'package:bible/infrastructure/theme/providers/theme.repository_provider.dart';
import 'package:bible/ui/pages/settings/settings.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  String? url;

  @override
  Future<String?> getBackendUrl() async => url;

  @override
  Future<void> setBackendUrl(String value) async => url = value;

  @override
  Future<void> clearBackendUrl() async => url = null;
}

class _InMemoryThemeRepository implements ThemeRepository {
  AppThemeMode mode = AppThemeMode.system;

  @override
  Future<AppThemeMode> getThemeMode() async => mode;

  @override
  Future<void> setThemeMode(AppThemeMode value) async => mode = value;
}

void main() {
  late _InMemorySettingsRepository settings;
  late _InMemoryThemeRepository theme;

  setUp(() {
    settings = _InMemorySettingsRepository();
    theme = _InMemoryThemeRepository();
    PackageInfo.setMockInitialValues(
      appName: 'Bible',
      packageName: 'fr.dtfh.bible',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          themeRepositoryProvider.overrideWithValue(theme),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Écran de réglages', () {
    testWidgets('enregistre le thème choisi', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.byKey(const Key('themeMode_dark')));
      await tester.pumpAndSettle();

      expect(theme.mode, AppThemeMode.dark);
    });

    testWidgets('affiche la version installée', (tester) async {
      await pumpSettings(tester);

      expect(find.text('1.2.3 (45)'), findsOneWidget);
    });

    testWidgets('affiche le serveur du build par défaut', (tester) async {
      await pumpSettings(tester);

      expect(find.text(ApiBaseUrl.kProductionApiBaseUrl), findsOneWidget);
      // Rien à réinitialiser tant que l'utilisateur n'a rien changé.
      expect(find.byKey(const Key('resetServerUrlTile')), findsNothing);
    });

    testWidgets('enregistre une autre URL de serveur, sans son chemin', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.byKey(const Key('serverUrlTile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('serverUrlField')),
        'https://recette.bible.test/',
      );
      await tester.tap(find.byKey(const Key('serverUrlSubmitButton')));
      await tester.pumpAndSettle();

      expect(settings.url, 'https://recette.bible.test');
      expect(find.text('https://recette.bible.test'), findsOneWidget);
      expect(find.byKey(const Key('resetServerUrlTile')), findsOneWidget);
    });

    testWidgets('refuse une URL comportant un chemin', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.byKey(const Key('serverUrlTile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('serverUrlField')),
        'https://bible.test/api',
      );
      await tester.tap(find.byKey(const Key('serverUrlSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.textContaining('sans chemin'), findsOneWidget);
      expect(settings.url, isNull);
    });

    testWidgets('revient au serveur du build', (tester) async {
      settings.url = 'https://recette.bible.test';
      await pumpSettings(tester);
      // L'écran lit l'URL du build ; on la remplace comme le ferait `main`.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      await container.read(apiBaseUrlProvider.notifier).load();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('resetServerUrlTile')));
      await tester.pumpAndSettle();

      expect(settings.url, isNull);
      expect(find.text(ApiBaseUrl.kProductionApiBaseUrl), findsOneWidget);
    });
  });
}
