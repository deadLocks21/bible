import 'package:bible/core/domain/services/settings.repository.dart';
import 'package:bible/infrastructure/settings/shared_preferences.settings.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.repository_provider.g.dart';

/// `keepAlive` : le dépôt porte un cache de `SharedPreferences` qu'il serait
/// inutile de reconstruire à chaque lecture.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SharedPreferencesSettingsRepository();
