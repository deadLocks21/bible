// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_stats.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Régularité et avancement de l'utilisateur.
///
/// Les statistiques accompagnent le tableau de bord sans le conditionner : un
/// échec de ce côté remonte en `AsyncError` et l'écran se contente de masquer
/// le bandeau, les lectures restent affichées.

@ProviderFor(ReadingStatsNotifier)
final readingStatsProvider = ReadingStatsNotifierProvider._();

/// Régularité et avancement de l'utilisateur.
///
/// Les statistiques accompagnent le tableau de bord sans le conditionner : un
/// échec de ce côté remonte en `AsyncError` et l'écran se contente de masquer
/// le bandeau, les lectures restent affichées.
final class ReadingStatsNotifierProvider
    extends $AsyncNotifierProvider<ReadingStatsNotifier, ReadingStatsDto?> {
  /// Régularité et avancement de l'utilisateur.
  ///
  /// Les statistiques accompagnent le tableau de bord sans le conditionner : un
  /// échec de ce côté remonte en `AsyncError` et l'écran se contente de masquer
  /// le bandeau, les lectures restent affichées.
  ReadingStatsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStatsNotifierHash();

  @$internal
  @override
  ReadingStatsNotifier create() => ReadingStatsNotifier();
}

String _$readingStatsNotifierHash() =>
    r'7c641ecda528f99add447454b8440a2e36d28b84';

/// Régularité et avancement de l'utilisateur.
///
/// Les statistiques accompagnent le tableau de bord sans le conditionner : un
/// échec de ce côté remonte en `AsyncError` et l'écran se contente de masquer
/// le bandeau, les lectures restent affichées.

abstract class _$ReadingStatsNotifier extends $AsyncNotifier<ReadingStatsDto?> {
  FutureOr<ReadingStatsDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReadingStatsDto?>, ReadingStatsDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReadingStatsDto?>, ReadingStatsDto?>,
              AsyncValue<ReadingStatsDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
