import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/ui/pages/dashboard/providers/reading_board.provider.dart';
import 'package:bible/ui/pages/dashboard/providers/reading_stats.provider.dart';
import 'package:bible/ui/pages/dashboard/providers/stats_expanded.provider.dart';
import 'package:bible/ui/pages/dashboard/widgets/stats_header.widget.dart';
import 'package:bible/ui/pages/dashboard/widgets/today_card.widget.dart';
import 'package:bible/ui/pages/dashboard/widgets/upcoming_row.widget.dart';
import 'package:bible/ui/pages/history/history.page.dart';
import 'package:bible/ui/pages/settings/settings.page.dart';
import 'package:bible/ui/widgets/section_label.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tableau de bord : la régularité de l'utilisateur, le plan actif, la lecture
/// du jour et les prochaines lectures. Pendant de `Pages/Dashboard.tsx` côté
/// web.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  /// Identifiant de la lecture en cours de marquage, pour n'occuper que la
  /// carte concernée pendant l'appel.
  String? _markingEntryId;

  Future<void> _refresh() async {
    final error = await ref.read(readingBoardProvider.notifier).refresh();
    await ref.read(readingStatsProvider.notifier).refresh();
    if (mounted && error != null) _announce(error);
  }

  void _announce(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('dashboardError'), content: Text(message)),
    );
  }

  Future<void> _markAsRead(String entryId) async {
    setState(() => _markingEntryId = entryId);
    final error = await ref
        .read(readingBoardProvider.notifier)
        .markAsRead(entryId);
    // La lecture validée déplace la série et l'avancement : le bandeau suit.
    if (error == null) await ref.read(readingStatsProvider.notifier).refresh();
    if (!mounted) return;
    setState(() => _markingEntryId = null);
    if (error != null) _announce(error);
  }

  /// Un tableau déjà chargé prime sur l'état de chargement ou d'erreur : le
  /// contenu reste à l'écran pendant un rafraîchissement plutôt que de laisser
  /// la place à un indicateur.
  Widget _body(AsyncValue<ReadingBoardState> boardState) {
    final value = boardState.value;
    if (value != null) {
      return _Content(
        state: value,
        markingEntryId: _markingEntryId,
        onMarkAsRead: _markAsRead,
      );
    }
    final error = boardState.error;
    if (error != null) {
      return _CenteredMessage(
        key: const Key('dashboardErrorState'),
        message: error is ReadingException
            ? error.message
            : 'Une erreur est survenue. Réessayez.',
        onRetry: _refresh,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(readingBoardProvider);
    final title = switch (boardState.value) {
      ReadingBoardAvailable(:final board) => board.planName,
      _ => 'Bible',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title, key: const Key('dashboardTitle')),
        actions: [
          IconButton(
            key: const Key('dashboardHistoryButton'),
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            key: const Key('dashboardSettingsButton'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Réglages',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _body(boardState),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ReadingBoardState state;
  final String? markingEntryId;
  final void Function(String entryId) onMarkAsRead;

  const _Content({
    required this.state,
    required this.markingEntryId,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ReadingBoardEmpty(:final message) => _CenteredMessage(
        key: const Key('dashboardNoPlanState'),
        message: message,
      ),
      ReadingBoardAvailable(:final board) => _Board(
        board: board,
        markingEntryId: markingEntryId,
        onMarkAsRead: onMarkAsRead,
      ),
    };
  }
}

class _Board extends StatelessWidget {
  final ReadingBoardDto board;
  final String? markingEntryId;
  final void Function(String entryId) onMarkAsRead;

  const _Board({
    required this.board,
    required this.markingEntryId,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final today = board.today;

    return ListView(
      // `always` : sans cela, une page trop courte pour défiler ne réagirait
      // pas au geste de rafraîchissement.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const _StatsHeaderSlot(),
        if (today == null)
          const Padding(
            key: Key('dashboardCompletedState'),
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'Vous avez terminé toutes les lectures de ce plan.',
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          const SectionLabel('Lecture du jour'),
          const SizedBox(height: 12),
          TodayCard(
            entry: today,
            marking: markingEntryId == today.id,
            onMarkAsRead: markingEntryId == null
                ? () => onMarkAsRead(today.id)
                : null,
          ),
        ],
        if (board.upcoming.isNotEmpty) ...[
          const SizedBox(height: 32),
          const SectionLabel('Prochaines lectures'),
          const SizedBox(height: 4),
          for (final (index, entry) in board.upcoming.indexed)
            UpcomingRow(entry: entry, rank: index + 1),
        ],
      ],
    );
  }
}

/// Le bandeau de régularité, quand il y a quelque chose à raconter.
///
/// Il complète le tableau de bord sans le conditionner : tant que les
/// statistiques ne sont pas là — ou qu'aucune lecture n'a été validée — la
/// place reste au plan.
class _StatsHeaderSlot extends ConsumerWidget {
  const _StatsHeaderSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(readingStatsProvider).value;
    if (stats == null || stats.isEmpty) return const SizedBox.shrink();
    return StatsHeader(
      stats: stats,
      expanded: ref.watch(statsExpandedProvider).value ?? false,
      onToggle: ref.read(statsExpandedProvider.notifier).toggle,
    );
  }
}

/// Message centré occupant la page, utilisé pour les états « aucun plan »,
/// « plan terminé » et « échec de chargement ».
class _CenteredMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _CenteredMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: [
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              key: const Key('dashboardRetryButton'),
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ),
        ],
      ],
    );
  }
}
