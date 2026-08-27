// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Client HTTP partagé par tous les `dio.*.repository.dart`.
///
/// L'`baseUrl` vient d'[apiBaseUrlProvider] : changer de serveur depuis les
/// réglages reconstruit ce provider, donc une nouvelle instance visant la
/// nouvelle origine (au prix du pool de connexions, négligeable pour un
/// changement aussi rare).
///
/// Des délais explicites sont indispensables : sans eux, un serveur injoignable
/// dont la connexion TCP reste ouverte sans répondre bloquerait l'écran
/// indéfiniment, au lieu de remonter une erreur affichable.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Client HTTP partagé par tous les `dio.*.repository.dart`.
///
/// L'`baseUrl` vient d'[apiBaseUrlProvider] : changer de serveur depuis les
/// réglages reconstruit ce provider, donc une nouvelle instance visant la
/// nouvelle origine (au prix du pool de connexions, négligeable pour un
/// changement aussi rare).
///
/// Des délais explicites sont indispensables : sans eux, un serveur injoignable
/// dont la connexion TCP reste ouverte sans répondre bloquerait l'écran
/// indéfiniment, au lieu de remonter une erreur affichable.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP partagé par tous les `dio.*.repository.dart`.
  ///
  /// L'`baseUrl` vient d'[apiBaseUrlProvider] : changer de serveur depuis les
  /// réglages reconstruit ce provider, donc une nouvelle instance visant la
  /// nouvelle origine (au prix du pool de connexions, négligeable pour un
  /// changement aussi rare).
  ///
  /// Des délais explicites sont indispensables : sans eux, un serveur injoignable
  /// dont la connexion TCP reste ouverte sans répondre bloquerait l'écran
  /// indéfiniment, au lieu de remonter une erreur affichable.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'65bf52e20e826701b81c9a2224e20c4ae4dd84aa';
