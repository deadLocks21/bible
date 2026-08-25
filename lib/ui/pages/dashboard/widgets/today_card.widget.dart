import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:bible/ui/pages/dashboard/widgets/bible_reader.widget.dart';
import 'package:flutter/material.dart';

/// La lecture du jour, traitée comme l'objet principal de l'écran : le passage
/// en grand, l'action pleine largeur sous lui, et le lecteur des chapitres.
///
/// Le bouton ne partage plus sa ligne avec le titre — un passage un peu long y
/// écrasait l'un ou l'autre.
class TodayCard extends StatelessWidget {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            entry.passages,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (entry.hasVideos) ...[
            const SizedBox(height: 20),
            // La clé porte l'identifiant de la lecture : quand la lecture du
            // jour change, le lecteur est recréé avec la nouvelle playlist
            // plutôt que réutilisé avec l'ancienne.
            BibleReader(key: ValueKey(entry.id), videos: entry.videos),
          ],
          const SizedBox(height: 20),
          if (marking)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            FilledButton.icon(
              key: const Key('markAsReadButton'),
              onPressed: onMarkAsRead,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Marquer comme lu'),
            ),
        ],
      ),
    );
  }
}
