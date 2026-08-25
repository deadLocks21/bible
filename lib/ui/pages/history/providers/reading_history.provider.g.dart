// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Charge l'historique page par page et l'accumule.
///
/// Les échecs du premier chargement remontent en `AsyncError` porteur d'une
/// [ReadingException] ; ceux d'une page suivante sont renvoyés à l'appelant,
/// pour ne pas faire disparaître la liste déjà affichée.

@ProviderFor(ReadingHistoryNotifier)
final readingHistoryProvider = ReadingHistoryNotifierProvider._();

/// Charge l'historique page par page et l'accumule.
///
/// Les échecs du premier chargement remontent en `AsyncError` porteur d'une
/// [ReadingException] ; ceux d'une page suivante sont renvoyés à l'appelant,
/// pour ne pas faire disparaître la liste déjà affichée.
final class ReadingHistoryNotifierProvider
    extends
        $AsyncNotifierProvider<ReadingHistoryNotifier, ReadingHistoryState> {
  /// Charge l'historique page par page et l'accumule.
  ///
  /// Les échecs du premier chargement remontent en `AsyncError` porteur d'une
  /// [ReadingException] ; ceux d'une page suivante sont renvoyés à l'appelant,
  /// pour ne pas faire disparaître la liste déjà affichée.
  ReadingHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryNotifierHash();

  @$internal
  @override
  ReadingHistoryNotifier create() => ReadingHistoryNotifier();
}

String _$readingHistoryNotifierHash() =>
    r'86201b6183c987cc9e1f1c154d2b7c54ebe6cfe1';

/// Charge l'historique page par page et l'accumule.
///
/// Les échecs du premier chargement remontent en `AsyncError` porteur d'une
/// [ReadingException] ; ceux d'une page suivante sont renvoyés à l'appelant,
/// pour ne pas faire disparaître la liste déjà affichée.

abstract class _$ReadingHistoryNotifier
    extends $AsyncNotifier<ReadingHistoryState> {
  FutureOr<ReadingHistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReadingHistoryState>, ReadingHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReadingHistoryState>, ReadingHistoryState>,
              AsyncValue<ReadingHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
