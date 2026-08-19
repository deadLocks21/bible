import 'package:bible/core/application/services/settings_application.service.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/theme/providers/theme.repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.service_provider.g.dart';

@Riverpod(keepAlive: true)
SettingsApplicationService settingsService(Ref ref) {
  return SettingsApplicationService(ref.watch(themeRepositoryProvider));
}

/// Préférence de thème courante, relue au démarrage puis maintenue en état.
///
/// Un échec de lecture retombe sur [AppThemeMode.system] : un réglage
/// illisible ne doit pas empêcher l'application de s'afficher.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<AppThemeMode> build() async {
    try {
      return await ref.watch(settingsServiceProvider).getThemeMode();
    } catch (e, stack) {
      ref
          .read(loggerProvider)
          .warn('settings.theme_mode.load_failed', error: e, stack: stack);
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      await ref.read(settingsServiceProvider).setThemeMode(mode);
      state = AsyncData(mode);
    } catch (e, stack) {
      ref
          .read(loggerProvider)
          .error('settings.theme_mode.save_failed', error: e, stack: stack);
      state = AsyncError(e, StackTrace.current);
    }
  }
}
