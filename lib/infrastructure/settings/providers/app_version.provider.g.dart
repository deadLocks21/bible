// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Version installée, sous la forme `1.2.3 (45)`.
///
/// Affichée dans les réglages : c'est la première information à demander à un
/// utilisateur qui signale un problème.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Version installée, sous la forme `1.2.3 (45)`.
///
/// Affichée dans les réglages : c'est la première information à demander à un
/// utilisateur qui signale un problème.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Version installée, sous la forme `1.2.3 (45)`.
  ///
  /// Affichée dans les réglages : c'est la première information à demander à un
  /// utilisateur qui signale un problème.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ff1eb5d2af994c051622516f93f238f401bb6abc';
