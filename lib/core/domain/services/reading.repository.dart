import 'package:bible/core/domain/model/reading_board.dart';
import 'package:bible/core/domain/model/reading_history.dart';

/// Contrat d'accès au plan de lecture actif, calqué sur l'API
/// (`GET /api/reading-plan`, `POST /api/reading-plan/entries/{id}/read`,
/// `DELETE /api/reading-plan/entries/{id}/read`,
/// `GET /api/reading-plan/history`).
///
/// Lève une `NoActivePlanException` quand aucun plan n'est assigné, une
/// `ReadingException` pour les autres échecs.
abstract interface class ReadingRepository {
  /// Plan actif et prochaines lectures non lues.
  Future<ReadingBoard> loadBoard();

  /// Marque une lecture comme lue et renvoie le tableau rafraîchi — l'API
  /// répond avec le nouvel état, ce qui évite un aller-retour.
  Future<ReadingBoard> markAsRead(String entryId);

  /// Repasse une lecture en non lue et renvoie le tableau rafraîchi.
  ///
  /// Seule la dernière lecture validée est concernée ; toute autre est refusée
  /// par le serveur.
  Future<ReadingBoard> markAsUnread(String entryId);

  /// Lectures déjà validées, de la plus récente à la plus ancienne, par pages
  /// numérotées à partir de 1.
  Future<ReadingHistory> loadHistory({int page});
}
