import 'package:flutter/material.dart';

/// Intitulé de section, en capitales espacées.
///
/// Faute de vraies petites capitales — la police système ne les garantit pas —
/// c'est le corps réduit et l'espacement qui tiennent le rôle d'étiquette :
/// annoncer sans concurrencer ce qui suit.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
