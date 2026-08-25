import 'package:bible/core/domain/services/dashboard_preferences.repository.dart';
import 'package:bible/infrastructure/settings/shared_preferences.dashboard_preferences.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_preferences.repository_provider.g.dart';

@Riverpod(keepAlive: true)
DashboardPreferencesRepository dashboardPreferencesRepository(Ref ref) =>
    SharedPreferencesDashboardPreferencesRepository();
