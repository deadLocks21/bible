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

String _$settingsServiceHash() => r'b393e1c59eb97b62ca90dc8d1d12624b7729f2fe';

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

/// Jeu de couleurs courant, relu au démarrage puis maintenu en état.
///
/// Un échec de lecture retombe sur [AppPalette.paper] : un réglage illisible ne
/// doit pas empêcher l'application de s'afficher.

@ProviderFor(PaletteNotifier)
final paletteProvider = PaletteNotifierProvider._();

/// Jeu de couleurs courant, relu au démarrage puis maintenu en état.
///
/// Un échec de lecture retombe sur [AppPalette.paper] : un réglage illisible ne
/// doit pas empêcher l'application de s'afficher.
final class PaletteNotifierProvider
    extends $AsyncNotifierProvider<PaletteNotifier, AppPalette> {
  /// Jeu de couleurs courant, relu au démarrage puis maintenu en état.
  ///
  /// Un échec de lecture retombe sur [AppPalette.paper] : un réglage illisible ne
  /// doit pas empêcher l'application de s'afficher.
  PaletteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paletteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paletteNotifierHash();

  @$internal
  @override
  PaletteNotifier create() => PaletteNotifier();
}

String _$paletteNotifierHash() => r'639ebb759901c5e2f150abe2f88cf88a87fe55aa';

/// Jeu de couleurs courant, relu au démarrage puis maintenu en état.
///
/// Un échec de lecture retombe sur [AppPalette.paper] : un réglage illisible ne
/// doit pas empêcher l'application de s'afficher.

abstract class _$PaletteNotifier extends $AsyncNotifier<AppPalette> {
  FutureOr<AppPalette> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppPalette>, AppPalette>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppPalette>, AppPalette>,
              AsyncValue<AppPalette>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
