import 'package:bible/core/domain/model/reading_board.dart';

/// Contrat d'accès au plan de lecture actif, calqué sur l'API
/// (`GET /api/reading-plan`, `POST /api/reading-plan/entries/{id}/read`).
///
/// Lève une `NoActivePlanException` quand aucun plan n'est assigné, une
/// `ReadingException` pour les autres échecs.
abstract interface class ReadingRepository {
  /// Plan actif et prochaines lectures non lues.
  Future<ReadingBoard> loadBoard();

  /// Marque une lecture comme lue et renvoie le tableau rafraîchi — l'API
  /// répond avec le nouvel état, ce qui évite un aller-retour.
  Future<ReadingBoard> markAsRead(String entryId);
}
