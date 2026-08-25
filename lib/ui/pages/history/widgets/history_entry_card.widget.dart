import 'package:bible/core/application/dtos/reading_history.dto.dart';
import 'package:bible/ui/widgets/french_date.dart';
import 'package:flutter/material.dart';

/// Une lecture passée : les passages lus, la date, et — pour la seule lecture
/// la plus récente — le bouton qui la repasse en non lue.
///
/// Pas de cadre : la liste se lit d'un trait, seule la lecture défaisable se
/// détache, par son bouton.
class HistoryEntryCard extends StatelessWidget {
  final ReadingHistoryEntryDto entry;

  /// Annulation en cours : le bouton laisse place à un indicateur, pour qu'un
  /// double appui n'envoie pas deux requêtes.
  final bool undoing;

  final VoidCallback? onUndo;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    this.undoing = false,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.passages,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDayAndTime(entry.readAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (entry.canUnread) ...[
            const SizedBox(width: 12),
            if (undoing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                key: const Key('markAsUnreadButton'),
                onPressed: onUndo,
                icon: const Icon(Icons.undo, size: 20),
                tooltip: 'Repasser en non lu',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ],
      ),
    );
  }
}
