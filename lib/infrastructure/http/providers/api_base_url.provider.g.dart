// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_base_url.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Ordre de résolution, du plus prioritaire au moins prioritaire :
///
/// 1. l'URL enregistrée depuis l'écran Réglages, quand l'utilisateur a voulu
///    viser un autre serveur que celui compilé (recette, instance locale) ;
/// 2. la constante de compilation `API_BASE_URL`, passée au build :
///    `flutter run --dart-define=API_BASE_URL=http://localhost:8000` ;
/// 3. [kProductionApiBaseUrl], pour qu'un build sans aucune configuration
///    parle tout de même au serveur de production.
///
/// [load] est appelé une fois au démarrage, avant le premier écran. Changer
/// l'URL via [update] émet un nouvel état, ce qui reconstruit [dioProvider] et
/// les repositories qui l'observent : l'appel suivant part sur le nouveau
/// serveur.

@ProviderFor(ApiBaseUrl)
final apiBaseUrlProvider = ApiBaseUrlProvider._();

/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Ordre de résolution, du plus prioritaire au moins prioritaire :
///
/// 1. l'URL enregistrée depuis l'écran Réglages, quand l'utilisateur a voulu
///    viser un autre serveur que celui compilé (recette, instance locale) ;
/// 2. la constante de compilation `API_BASE_URL`, passée au build :
///    `flutter run --dart-define=API_BASE_URL=http://localhost:8000` ;
/// 3. [kProductionApiBaseUrl], pour qu'un build sans aucune configuration
///    parle tout de même au serveur de production.
///
/// [load] est appelé une fois au démarrage, avant le premier écran. Changer
/// l'URL via [update] émet un nouvel état, ce qui reconstruit [dioProvider] et
/// les repositories qui l'observent : l'appel suivant part sur le nouveau
/// serveur.
final class ApiBaseUrlProvider extends $NotifierProvider<ApiBaseUrl, String> {
  /// URL du serveur visée par l'application, lue de façon synchrone par
  /// [dioProvider].
  ///
  /// Ordre de résolution, du plus prioritaire au moins prioritaire :
  ///
  /// 1. l'URL enregistrée depuis l'écran Réglages, quand l'utilisateur a voulu
  ///    viser un autre serveur que celui compilé (recette, instance locale) ;
  /// 2. la constante de compilation `API_BASE_URL`, passée au build :
  ///    `flutter run --dart-define=API_BASE_URL=http://localhost:8000` ;
  /// 3. [kProductionApiBaseUrl], pour qu'un build sans aucune configuration
  ///    parle tout de même au serveur de production.
  ///
  /// [load] est appelé une fois au démarrage, avant le premier écran. Changer
  /// l'URL via [update] émet un nouvel état, ce qui reconstruit [dioProvider] et
  /// les repositories qui l'observent : l'appel suivant part sur le nouveau
  /// serveur.
  ApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  ApiBaseUrl create() => ApiBaseUrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'64a137fe51457f5c2066a5530f54e5fe0c9a85b0';

/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Ordre de résolution, du plus prioritaire au moins prioritaire :
///
/// 1. l'URL enregistrée depuis l'écran Réglages, quand l'utilisateur a voulu
///    viser un autre serveur que celui compilé (recette, instance locale) ;
/// 2. la constante de compilation `API_BASE_URL`, passée au build :
///    `flutter run --dart-define=API_BASE_URL=http://localhost:8000` ;
/// 3. [kProductionApiBaseUrl], pour qu'un build sans aucune configuration
///    parle tout de même au serveur de production.
///
/// [load] est appelé une fois au démarrage, avant le premier écran. Changer
/// l'URL via [update] émet un nouvel état, ce qui reconstruit [dioProvider] et
/// les repositories qui l'observent : l'appel suivant part sur le nouveau
/// serveur.

abstract class _$ApiBaseUrl extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
