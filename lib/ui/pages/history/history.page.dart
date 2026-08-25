import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/ui/pages/dashboard/providers/reading_board.provider.dart';
import 'package:bible/ui/pages/history/providers/reading_history.provider.dart';
import 'package:bible/ui/pages/dashboard/providers/reading_stats.provider.dart';
import 'package:bible/ui/pages/history/widgets/history_entry_card.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Historique de lecture : ce qui a été lu et quand, de la lecture la plus
/// récente à la plus ancienne, page par page.
///
/// Seule la dernière lecture validée peut être repassée en non lue — la règle
/// vient du serveur, l'écran se contente d'afficher le bouton là où elle
/// s'applique.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final ScrollController _scroll = ScrollController();

  /// Identifiant de la lecture en cours d'annulation, pour n'occuper que la
  /// ligne concernée pendant l'appel.
  String? _undoingEntryId;

  /// Chargement de la page suivante en cours : le geste de défilement peut
  /// déclencher plusieurs fois, l'appel ne doit partir qu'une fois.
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 300) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final state = ref.read(readingHistoryProvider).value;
    if (state is! ReadingHistoryAvailable || !state.hasMore) return;

    setState(() => _loadingMore = true);
    final error = await ref.read(readingHistoryProvider.notifier).loadMore();
    if (!mounted) return;
    setState(() => _loadingMore = false);
    if (error != null) _announce(error);
  }

  Future<void> _refresh() async {
    final error = await ref.read(readingHistoryProvider.notifier).refresh();
    if (mounted && error != null) _announce(error);
  }

  void _announce(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('historyError'), content: Text(message)),
    );
  }

  /// Repasse une lecture en non lue. Le tableau de bord porte l'appel : c'est
  /// lui qui détient l'état du plan, et l'API renvoie le tableau rafraîchi.
  /// L'historique est ensuite rechargé pour refléter la lecture rendue.
  Future<void> _undo(String entryId) async {
    setState(() => _undoingEntryId = entryId);
    final error = await ref
        .read(readingBoardProvider.notifier)
        .markAsUnread(entryId);
    if (mounted && error == null) {
      await ref.read(readingHistoryProvider.notifier).refresh();
      await ref.read(readingStatsProvider.notifier).refresh();
    }
    if (!mounted) return;
    setState(() => _undoingEntryId = null);
    if (error != null) _announce(error);
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(readingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique', key: Key('historyTitle')),
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _body(historyState)),
    );
  }

  /// Une liste déjà chargée prime sur l'état de chargement ou d'erreur : elle
  /// reste à l'écran pendant un rafraîchissement.
  Widget _body(AsyncValue<ReadingHistoryState> historyState) {
    final value = historyState.value;
    if (value != null) return _content(value);

    final error = historyState.error;
    if (error != null) {
      return _Message(
        key: const Key('historyErrorState'),
        message: error is ReadingException
            ? error.message
            : 'Une erreur est survenue. Réessayez.',
        onRetry: _refresh,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _content(ReadingHistoryState state) => switch (state) {
    ReadingHistoryEmpty(:final message) => _Message(
      key: const Key('historyNoPlanState'),
      message: message,
    ),
    ReadingHistoryAvailable(:final entries) when entries.isEmpty => const _Message(
      key: Key('historyEmptyState'),
      message: 'Aucune lecture validée pour le moment.',
    ),
    ReadingHistoryAvailable(:final entries) => ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      // Une ligne de plus quand une page suivante reste à charger : elle porte
      // l'indicateur de chargement en bas de liste.
      itemCount: entries.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Padding(
            key: Key('historyLoadingMore'),
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final entry = entries[index];
        return HistoryEntryCard(
          entry: entry,
          undoing: _undoingEntryId == entry.id,
          onUndo: _undoingEntryId == null ? () => _undo(entry.id) : null,
        );
      },
    ),
  };

}

/// Message centré occupant la page, pour les états « aucun plan », « aucune
/// lecture » et « échec de chargement ».
class _Message extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _Message({super.key, required this.message, this.onRetry});

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
              key: const Key('historyRetryButton'),
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ),
        ],
      ],
    );
  }
}
