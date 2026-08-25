import 'package:bible/core/application/dtos/reading_history.dto.dart';
import 'package:flutter/material.dart';

/// Ligne d'historique : les passages lus, la date de lecture, et — pour la
/// seule lecture la plus récente — le bouton qui la repasse en non lue.
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.passages,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lu le ${formatReadAt(entry.readAt)}',
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
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              OutlinedButton.icon(
                key: const Key('markAsUnreadButton'),
                onPressed: onUndo,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Non lu'),
              ),
          ],
        ],
      ),
    );
  }
}

/// Date de lecture en français, ex. « 24 août 2026 à 09:12 ».
///
/// Écrite à la main : l'application n'embarque pas `intl`, et un seul format
/// suffit ici.
String formatReadAt(DateTime date) {
  const months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${months[local.month - 1]} ${local.year} '
      'à $hour:$minute';
}
