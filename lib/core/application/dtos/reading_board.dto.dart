import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:bible/core/domain/model/reading_board.dart';

/// Projection du tableau de bord pour l'UI : le plan, la lecture du jour et
/// les lectures suivantes, déjà réparties selon la règle du domaine.
class ReadingBoardDto {
  final String planName;
  final String planSource;

  /// Lecture du jour, `null` quand le plan est terminé.
  final ReadingEntryDto? today;

  /// Lectures suivantes, non marquables comme lues.
  final List<ReadingEntryDto> upcoming;

  const ReadingBoardDto({
    required this.planName,
    required this.planSource,
    required this.today,
    required this.upcoming,
  });

  factory ReadingBoardDto.fromDomain(ReadingBoard board) {
    final today = board.today;
    return ReadingBoardDto(
      planName: board.plan.name,
      planSource: board.plan.source,
      today: today == null
          ? null
          : ReadingEntryDto.fromDomain(today, canMarkAsRead: true),
      upcoming: board.upcoming
          .map((entry) => ReadingEntryDto.fromDomain(entry, canMarkAsRead: false))
          .toList(),
    );
  }

  /// Vrai quand plus aucune lecture n'attend l'utilisateur.
  bool get isCompleted => today == null;
}
