import 'package:bible/core/domain/services/theme.repository.dart';
import 'package:bible/infrastructure/theme/shared_preferences.theme.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.repository_provider.g.dart';

@Riverpod(keepAlive: true)
ThemeRepository themeRepository(Ref ref) => SharedPreferencesThemeRepository();
