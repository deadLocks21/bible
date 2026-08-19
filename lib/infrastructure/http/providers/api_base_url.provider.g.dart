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
/// Elle est fixée à la compilation, et à elle seule :
/// `flutter run --dart-define=API_BASE_URL=http://localhost:8000`. Sans rien,
/// l'application parle à la production.
///
/// Elle est normalisée en origine : un `--dart-define` qui traînerait une barre
/// oblique finale ou un chemin ne produit pas d'URL d'appel bancale.

@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = ApiBaseUrlProvider._();

/// URL du serveur visée par l'application, lue de façon synchrone par
/// [dioProvider].
///
/// Elle est fixée à la compilation, et à elle seule :
/// `flutter run --dart-define=API_BASE_URL=http://localhost:8000`. Sans rien,
/// l'application parle à la production.
///
/// Elle est normalisée en origine : un `--dart-define` qui traînerait une barre
/// oblique finale ou un chemin ne produit pas d'URL d'appel bancale.

final class ApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// URL du serveur visée par l'application, lue de façon synchrone par
  /// [dioProvider].
  ///
  /// Elle est fixée à la compilation, et à elle seule :
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:8000`. Sans rien,
  /// l'application parle à la production.
  ///
  /// Elle est normalisée en origine : un `--dart-define` qui traînerait une barre
  /// oblique finale ou un chemin ne produit pas d'URL d'appel bancale.
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
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'989fed2615ce6b42cd942ea5d3a32c5cb3d517ee';
