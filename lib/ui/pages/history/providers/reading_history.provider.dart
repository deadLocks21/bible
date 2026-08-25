import 'package:bible/core/application/dtos/reading_history.dto.dart';
import 'package:bible/core/application/usecases/load_reading_history.usecase.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/infrastructure/reading/providers/reading.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_history.provider.g.dart';

/// Contenu de l'historique, une fois le chargement abouti.
sealed class ReadingHistoryState {
  const ReadingHistoryState();
}

/// Les lectures déjà validées, de la plus récente à la plus ancienne, et le
/// fait qu'une page suivante reste à charger.
class ReadingHistoryAvailable extends ReadingHistoryState {
  final List<ReadingHistoryEntryDto> entries;
  final bool hasMore;

  /// Numéro de la dernière page chargée.
  final int page;

  const ReadingHistoryAvailable({
    required this.entries,
    required this.hasMore,
    required this.page,
  });

  bool get isEmpty => entries.isEmpty;
}

/// Aucun plan actif : rien à raconter. État nominal, comme sur le tableau de
/// bord.
class ReadingHistoryEmpty extends ReadingHistoryState {
  final String message;

  const ReadingHistoryEmpty(this.message);
}

/// Charge l'historique page par page et l'accumule.
///
/// Les échecs du premier chargement remontent en `AsyncError` porteur d'une
/// [ReadingException] ; ceux d'une page suivante sont renvoyés à l'appelant,
/// pour ne pas faire disparaître la liste déjà affichée.
@riverpod
class ReadingHistoryNotifier extends _$ReadingHistoryNotifier {
  @override
  Future<ReadingHistoryState> build() async {
    final result = await _execute(1);
    return switch (result) {
      ReadingHistoryLoaded(:final history) => _appended(null, history),
      ReadingHistoryNoActivePlan(:final message) => ReadingHistoryEmpty(message),
      ReadingHistoryFailure(:final message) => throw ReadingException(message),
    };
  }

  /// Recharge depuis la première page, en oubliant les pages accumulées.
  ///
  /// Renvoie `null` en cas de succès, sinon le message à afficher.
  Future<String?> refresh() => _load(1, append: false);

  /// Charge la page suivante, si elle existe. Sans effet quand la liste est
  /// déjà complète ou qu'aucun chargement n'a encore abouti.
  Future<String?> loadMore() {
    final current = state.value;
    if (current is! ReadingHistoryAvailable || !current.hasMore) {
      return Future.value();
    }
    return _load(current.page + 1, append: true);
  }

  Future<String?> _load(int page, {required bool append}) async {
    final result = await _execute(page);
    switch (result) {
      case ReadingHistoryLoaded(:final history):
        final previous = append ? state.value : null;
        state = AsyncData(_appended(previous, history));
        return null;
      case ReadingHistoryNoActivePlan(:final message):
        state = AsyncData(ReadingHistoryEmpty(message));
        return null;
      case ReadingHistoryFailure(:final message):
        if (!state.hasValue) {
          state = AsyncError(ReadingException(message), StackTrace.current);
        }
        return message;
    }
  }

  Future<ReadingHistoryResult> _execute(int page) =>
      ref.read(readingServiceProvider).loadHistory.execute(page: page);

  /// Ajoute une page à celles déjà affichées. [previous] à `null` repart de
  /// zéro : c'est le cas du premier chargement et d'un rafraîchissement.
  ReadingHistoryAvailable _appended(
    ReadingHistoryState? previous,
    ReadingHistoryDto history,
  ) => ReadingHistoryAvailable(
    entries: [
      if (previous is ReadingHistoryAvailable) ...previous.entries,
      ...history.entries,
    ],
    hasMore: history.hasMore,
    page: history.page,
  );
}
