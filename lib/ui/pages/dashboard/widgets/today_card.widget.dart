import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:bible/ui/pages/dashboard/widgets/bible_reader.widget.dart';
import 'package:flutter/material.dart';

/// La lecture du jour, traitée comme l'objet principal de l'écran : le passage
/// en grand, l'action de validation, et le lecteur des chapitres.
///
/// La place de l'action dépend du large disponible. Au large — écran
/// d'ordinateur, tablette — elle tient sur la ligne du passage, là où l'œil
/// l'attend. À l'étroit, elle passe en pleine largeur sous lui : partager la
/// ligne écraserait l'un ou l'autre dès qu'un passage s'allonge.
class TodayCard extends StatelessWidget {
  /// Largeur à partir de laquelle le passage et l'action tiennent sur la même
  /// ligne.
  static const double _inlineActionBreakpoint = 520;

  final ReadingEntryDto entry;

  /// Marquage en cours : le bouton laisse place à un indicateur, pour qu'un
  /// double appui n'envoie pas deux requêtes.
  final bool marking;

  final VoidCallback? onMarkAsRead;

  const TodayCard({
    super.key,
    required this.entry,
    this.marking = false,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Un cadre dessiné, et surtout pas une `Card` : celle-ci est un `Material`
    // porteur d'une forme, donc un calque de forme physique au-dessus de la vue
    // native du lecteur — ce qui décale sa zone cliquable et le rend inerte
    // (même mécanisme qu'un `ClipRRect`, cf. `BibleReader`).
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inlineAction = constraints.maxWidth >= _inlineActionBreakpoint;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (inlineAction)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _Passages(entry: entry)),
                    const SizedBox(width: 20),
                    _Action(marking: marking, onMarkAsRead: onMarkAsRead),
                  ],
                )
              else
                _Passages(entry: entry),
              if (entry.hasVideos) ...[
                const SizedBox(height: 20),
                // La clé porte l'identifiant de la lecture : quand la lecture
                // du jour change, le lecteur est recréé avec la nouvelle
                // playlist plutôt que réutilisé avec l'ancienne.
                BibleReader(key: ValueKey(entry.id), videos: entry.videos),
              ],
              if (!inlineAction) ...[
                const SizedBox(height: 20),
                _Action(marking: marking, onMarkAsRead: onMarkAsRead),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Passages extends StatelessWidget {
  final ReadingEntryDto entry;

  const _Passages({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Text(
      entry.passages,
      style: Theme.of(context).textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
    );
  }
}

/// Le bouton de validation, ou l'indicateur qui le remplace pendant l'appel.
class _Action extends StatelessWidget {
  final bool marking;
  final VoidCallback? onMarkAsRead;

  const _Action({required this.marking, required this.onMarkAsRead});

  @override
  Widget build(BuildContext context) {
    if (marking) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return FilledButton.icon(
      key: const Key('markAsReadButton'),
      onPressed: onMarkAsRead,
      icon: const Icon(Icons.check, size: 20),
      label: const Text('Marquer comme lu'),
    );
  }
}
