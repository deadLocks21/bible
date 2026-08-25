// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_expanded.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bandeau de régularité déplié ou replié, tel que l'utilisateur l'a laissé.
///
/// Replié par défaut : le tableau de bord existe d'abord pour la lecture du
/// jour, que le bandeau ne doit pas repousser hors de l'écran. Un réglage
/// illisible retombe sur ce même défaut plutôt que d'empêcher l'affichage.

@ProviderFor(StatsExpandedNotifier)
final statsExpandedProvider = StatsExpandedNotifierProvider._();

/// Bandeau de régularité déplié ou replié, tel que l'utilisateur l'a laissé.
///
/// Replié par défaut : le tableau de bord existe d'abord pour la lecture du
/// jour, que le bandeau ne doit pas repousser hors de l'écran. Un réglage
/// illisible retombe sur ce même défaut plutôt que d'empêcher l'affichage.
final class StatsExpandedNotifierProvider
    extends $AsyncNotifierProvider<StatsExpandedNotifier, bool> {
  /// Bandeau de régularité déplié ou replié, tel que l'utilisateur l'a laissé.
  ///
  /// Replié par défaut : le tableau de bord existe d'abord pour la lecture du
  /// jour, que le bandeau ne doit pas repousser hors de l'écran. Un réglage
  /// illisible retombe sur ce même défaut plutôt que d'empêcher l'affichage.
  StatsExpandedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsExpandedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsExpandedNotifierHash();

  @$internal
  @override
  StatsExpandedNotifier create() => StatsExpandedNotifier();
}

String _$statsExpandedNotifierHash() =>
    r'2a2c530b2ae2121b545d930943008933722bd3d1';

/// Bandeau de régularité déplié ou replié, tel que l'utilisateur l'a laissé.
///
/// Replié par défaut : le tableau de bord existe d'abord pour la lecture du
/// jour, que le bandeau ne doit pas repousser hors de l'écran. Un réglage
/// illisible retombe sur ce même défaut plutôt que d'empêcher l'affichage.

abstract class _$StatsExpandedNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
