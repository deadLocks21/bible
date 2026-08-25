// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_preferences.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardPreferencesRepository)
final dashboardPreferencesRepositoryProvider =
    DashboardPreferencesRepositoryProvider._();

final class DashboardPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          DashboardPreferencesRepository,
          DashboardPreferencesRepository,
          DashboardPreferencesRepository
        >
    with $Provider<DashboardPreferencesRepository> {
  DashboardPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<DashboardPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardPreferencesRepository create(Ref ref) {
    return dashboardPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardPreferencesRepository>(
        value,
      ),
    );
  }
}

String _$dashboardPreferencesRepositoryHash() =>
    r'2a6cf8bee5967430d4f9deaa5eb20027a7dbe03a';
