import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:flutter/material.dart';

/// Une lecture à venir : une simple ligne, sans cadre ni bouton.
///
/// On n'avance dans un plan que dans l'ordre : ces lectures sont là pour se
/// projeter, pas pour agir. Le rang les situe dans la file.
class UpcomingRow extends StatelessWidget {
  final ReadingEntryDto entry;

  /// Position dans la file, à partir de 1 pour la lecture suivant celle du
  /// jour.
  final int rank;

  const UpcomingRow({super.key, required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(entry.passages, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
