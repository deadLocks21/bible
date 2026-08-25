import 'package:bible/core/application/dtos/reading_stats.dto.dart';
import 'package:bible/ui/widgets/french_date.dart';
import 'package:flutter/material.dart';

/// Bandeau de régularité en tête du tableau de bord : la série en cours, le
/// record et l'avancement dans le plan.
///
/// Replié, il tient sur une ligne — la lecture du jour reste ce que l'écran
/// montre en premier. Un appui le déplie, et le choix est retenu par
/// l'appelant.
class StatsHeader extends StatelessWidget {
  final ReadingStatsDto stats;

  final bool expanded;

  final VoidCallback onToggle;

  const StatsHeader({
    super.key,
    required this.stats,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('dashboardStats'),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('dashboardStatsToggle'),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(16),
          // La taille s'anime : déplier ne doit pas faire sauter la lecture du
          // jour d'un coup sous le doigt.
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: expanded ? _Expanded(stats: stats) : _Collapsed(stats: stats),
          ),
        ),
      ),
    );
  }
}

/// Une ligne : l'essentiel de la régularité, et le chevron qui invite à ouvrir.
class _Collapsed extends StatelessWidget {
  final ReadingStatsDto stats;

  const _Collapsed({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            '${_days(stats.currentStreak)} d\'affilée '
            '· ${stats.progressPercent} % du plan',
            key: const Key('dashboardStatsSummary'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }
}

/// Le bandeau complet.
class _Expanded extends StatelessWidget {
  final ReadingStatsDto stats;

  const _Expanded({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstReadAt = stats.firstReadAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Figure(
                key: const Key('dashboardCurrentStreak'),
                value: _days(stats.currentStreak),
                label: 'Série en cours',
              ),
            ),
            Expanded(
              child: _Figure(value: _days(stats.longestStreak), label: 'Record'),
            ),
            Icon(Icons.expand_less, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 16),
        _Progress(stats: stats),
        if (firstReadAt != null) ...[
          const SizedBox(height: 16),
          Text(
            'Depuis le ${formatDay(firstReadAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// « 1 jour », « 5 jours » — l'unité fait toute la lisibilité du chiffre.
String _days(int count) => count > 1 ? '$count jours' : '$count jour';

/// Intitulé d'une mesure, en capitales espacées — faute de vraies petites
/// capitales, que la police système ne garantit pas. Le rôle est d'étiqueter
/// sans concurrencer ce qui est mesuré.
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

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

/// Ce qui est mesuré, puis le chiffre.
class _Figure extends StatelessWidget {
  final String value;
  final String label;

  const _Figure({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Avancement dans le plan : la barre, et le compte exact sous elle.
class _Progress extends StatelessWidget {
  final ReadingStatsDto stats;

  const _Progress({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      // `stretch` : la barre n'a pas de largeur propre, elle prend celle du
      // bandeau. Le texte, lui, reste calé à gauche.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label('Avancement'),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            key: const Key('dashboardProgressBar'),
            value: stats.progress,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${stats.readCount} lecture${stats.readCount > 1 ? 's' : ''} '
          'sur ${stats.planEntryCount} — ${stats.progressPercent} %',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
