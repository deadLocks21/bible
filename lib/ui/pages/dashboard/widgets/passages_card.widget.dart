import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:bible/ui/pages/dashboard/widgets/bible_reader.widget.dart';
import 'package:flutter/material.dart';

/// Carte d'une lecture : ses passages, le bouton « Marquer comme lu » quand
/// c'est la lecture du jour, et le lecteur des chapitres correspondants.
///
/// Les lectures suivantes n'affichent ni bouton ni lecteur : on n'avance dans
/// un plan que dans l'ordre, et le web fait de même.
class PassagesCard extends StatelessWidget {
  final ReadingEntryDto entry;

  /// Marquage en cours pour cette lecture : le bouton laisse place à un
  /// indicateur, pour qu'un double appui n'envoie pas deux requêtes.
  final bool marking;

  final VoidCallback? onMarkAsRead;

  const PassagesCard({
    super.key,
    required this.entry,
    this.marking = false,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    // Un cadre dessiné, et surtout pas une `Card` : celle-ci est un `Material`
    // porteur d'une forme, donc un calque de forme physique au-dessus de la
    // vue native du lecteur — ce qui décale sa zone cliquable et le rend
    // inerte (même mécanisme qu'un `ClipRRect`, cf. `BibleReader`).
    //
    // Le web dessine d'ailleurs ces cartes avec un simple `border rounded`,
    // pas une carte Material : le rendu s'en rapproche.
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.passages,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (entry.canMarkAsRead) ...[
                const SizedBox(width: 12),
                if (marking)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  FilledButton.icon(
                    key: const Key('markAsReadButton'),
                    onPressed: onMarkAsRead,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Marquer comme lu'),
                  ),
              ],
            ],
          ),
          if (entry.canMarkAsRead && entry.hasVideos) ...[
            const SizedBox(height: 16),
            // La clé porte l'identifiant de la lecture : quand la lecture du
            // jour change, le lecteur est recréé avec la nouvelle playlist
            // plutôt que réutilisé avec l'ancienne.
            BibleReader(key: ValueKey(entry.id), videos: entry.videos),
          ],
        ],
      ),
    );
  }
}
