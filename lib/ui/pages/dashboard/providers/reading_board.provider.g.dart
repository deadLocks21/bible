// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_board.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Charge le tableau de bord et le tient à jour.
///
/// Les échecs remontent en `AsyncError` porteur d'une [ReadingException] : le
/// message reste celui produit par le cas d'usage, l'écran n'en fabrique pas.

@ProviderFor(ReadingBoardNotifier)
final readingBoardProvider = ReadingBoardNotifierProvider._();

/// Charge le tableau de bord et le tient à jour.
///
/// Les échecs remontent en `AsyncError` porteur d'une [ReadingException] : le
/// message reste celui produit par le cas d'usage, l'écran n'en fabrique pas.
final class ReadingBoardNotifierProvider
    extends $AsyncNotifierProvider<ReadingBoardNotifier, ReadingBoardState> {
  /// Charge le tableau de bord et le tient à jour.
  ///
  /// Les échecs remontent en `AsyncError` porteur d'une [ReadingException] : le
  /// message reste celui produit par le cas d'usage, l'écran n'en fabrique pas.
  ReadingBoardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingBoardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingBoardNotifierHash();

  @$internal
  @override
  ReadingBoardNotifier create() => ReadingBoardNotifier();
}

String _$readingBoardNotifierHash() =>
    r'ae64e6749efa1bf5a17c4121cba4109a5ce4dda8';

/// Charge le tableau de bord et le tient à jour.
///
/// Les échecs remontent en `AsyncError` porteur d'une [ReadingException] : le
/// message reste celui produit par le cas d'usage, l'écran n'en fabrique pas.

abstract class _$ReadingBoardNotifier
    extends $AsyncNotifier<ReadingBoardState> {
  FutureOr<ReadingBoardState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReadingBoardState>, ReadingBoardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReadingBoardState>, ReadingBoardState>,
              AsyncValue<ReadingBoardState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
