// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends
        $FunctionalProvider<
          SettingsApplicationService,
          SettingsApplicationService,
          SettingsApplicationService
        >
    with $Provider<SettingsApplicationService> {
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  $ProviderElement<SettingsApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsApplicationService create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsApplicationService>(value),
    );
  }
}

String _$settingsServiceHash() => r'a93ff14bcfea198bc6c94a24ed45c050a264bd1c';

/// Préférence de thème courante, relue au démarrage puis maintenue en état.
///
/// Un échec de lecture retombe sur [AppThemeMode.system] : un réglage
/// illisible ne doit pas empêcher l'application de s'afficher.

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// Préférence de thème courante, relue au démarrage puis maintenue en état.
///
/// Un échec de lecture retombe sur [AppThemeMode.system] : un réglage
/// illisible ne doit pas empêcher l'application de s'afficher.
final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, AppThemeMode> {
  /// Préférence de thème courante, relue au démarrage puis maintenue en état.
  ///
  /// Un échec de lecture retombe sur [AppThemeMode.system] : un réglage
  /// illisible ne doit pas empêcher l'application de s'afficher.
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'93d626443db636c46ab9346dee28505015759eb0';

/// Préférence de thème courante, relue au démarrage puis maintenue en état.
///
/// Un échec de lecture retombe sur [AppThemeMode.system] : un réglage
/// illisible ne doit pas empêcher l'application de s'afficher.

abstract class _$ThemeModeNotifier extends $AsyncNotifier<AppThemeMode> {
  FutureOr<AppThemeMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppThemeMode>, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeMode>, AppThemeMode>,
              AsyncValue<AppThemeMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
