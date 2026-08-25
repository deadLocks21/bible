import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:bible/core/application/usecases/load_reading_board.usecase.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/infrastructure/reading/providers/reading.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_board.provider.g.dart';

/// Contenu du tableau de bord, une fois le chargement abouti.
sealed class ReadingBoardState {
  const ReadingBoardState();
}

/// Un plan actif et ses prochaines lectures.
class ReadingBoardAvailable extends ReadingBoardState {
  final ReadingBoardDto board;

  const ReadingBoardAvailable(this.board);
}

/// Aucun plan actif assigné. État nominal — l'assignation se fait côté serveur
/// — et non une panne : l'écran l'explique au lieu d'inviter à réessayer.
class ReadingBoardEmpty extends ReadingBoardState {
  final String message;

  const ReadingBoardEmpty(this.message);
}

/// Charge le tableau de bord et le tient à jour.
///
/// Les échecs remontent en `AsyncError` porteur d'une [ReadingException] : le
/// message reste celui produit par le cas d'usage, l'écran n'en fabrique pas.
@riverpod
class ReadingBoardNotifier extends _$ReadingBoardNotifier {
  @override
  Future<ReadingBoardState> build() =>
      _toState(ref.watch(readingServiceProvider).loadBoard.execute());

  /// Recharge depuis le serveur.
  ///
  /// Renvoie `null` en cas de succès, sinon le message à afficher. Quand un
  /// tableau est déjà affiché, un échec le laisse en place : un rafraîchissement
  /// raté ne doit pas remplacer les lectures par une page d'erreur.
  Future<String?> refresh() async {
    final result = await ref.read(readingServiceProvider).loadBoard.execute();
    switch (result) {
      case ReadingBoardLoaded(:final board):
        state = AsyncData(ReadingBoardAvailable(board));
        return null;
      case ReadingBoardNoActivePlan(:final message):
        state = AsyncData(ReadingBoardEmpty(message));
        return null;
      case ReadingBoardFailure(:final message):
        if (!state.hasValue) {
          state = AsyncError(ReadingException(message), StackTrace.current);
        }
        return message;
    }
  }

  /// Marque une lecture comme lue. Renvoie `null` en cas de succès, sinon le
  /// message à afficher — sans écraser le tableau déjà affiché : un échec ne
  /// doit pas faire disparaître les lectures sous les yeux de l'utilisateur.
  Future<String?> markAsRead(String entryId) async {
    final result = await ref
        .read(readingServiceProvider)
        .markEntryAsRead
        .execute(entryId);
    switch (result) {
      case ReadingBoardLoaded(:final board):
        state = AsyncData(ReadingBoardAvailable(board));
        return null;
      case ReadingBoardNoActivePlan(:final message):
        state = AsyncData(ReadingBoardEmpty(message));
        return null;
      case ReadingBoardFailure(:final message):
        return message;
    }
  }

  /// Repasse une lecture en non lue. Même contrat que [markAsRead] : `null` en
  /// cas de succès, sinon le message à afficher, sans écraser le tableau.
  Future<String?> markAsUnread(String entryId) async {
    final result = await ref
        .read(readingServiceProvider)
        .markEntryAsUnread
        .execute(entryId);
    switch (result) {
      case ReadingBoardLoaded(:final board):
        state = AsyncData(ReadingBoardAvailable(board));
        return null;
      case ReadingBoardNoActivePlan(:final message):
        state = AsyncData(ReadingBoardEmpty(message));
        return null;
      case ReadingBoardFailure(:final message):
        return message;
    }
  }

  Future<ReadingBoardState> _toState(Future<ReadingBoardResult> future) async {
    final result = await future;
    return switch (result) {
      ReadingBoardLoaded(:final board) => ReadingBoardAvailable(board),
      ReadingBoardNoActivePlan(:final message) => ReadingBoardEmpty(message),
      ReadingBoardFailure(:final message) => throw ReadingException(message),
    };
  }
}
