import 'package:bible/core/domain/model/reading_entry.dart';
import 'package:bible/core/domain/model/reading_plan.dart';

/// État de l'avancement de l'utilisateur dans son plan actif : le plan, et ses
/// prochaines lectures non lues dans l'ordre du plan.
///
/// La règle « la première lecture non lue est la lecture du jour » est portée
/// ici, et non par l'écran : c'est elle qui définit ce que l'utilisateur peut
/// marquer comme lu.
class ReadingBoard {
  final ReadingPlan plan;

  /// Lectures non encore lues, dans l'ordre du plan. Le serveur en renvoie au
  /// plus six.
  final List<ReadingEntry> entries;

  const ReadingBoard({required this.plan, required this.entries});

  /// Lecture du jour, ou `null` quand le plan est terminé.
  ReadingEntry? get today => entries.isEmpty ? null : entries.first;

  /// Lectures suivantes, affichées mais non marquables comme lues : on ne peut
  /// avancer dans un plan que dans l'ordre.
  List<ReadingEntry> get upcoming =>
      entries.isEmpty ? const [] : entries.sublist(1);

  /// Vrai quand plus aucune lecture n'attend l'utilisateur.
  bool get isCompleted => entries.isEmpty;
}
