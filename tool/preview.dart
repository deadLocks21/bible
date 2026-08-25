/// Aperçu de l'interface avec des données fabriquées, sans serveur.
///
/// Hors de `lib/` : ce fichier ne part pas dans l'application. Il sert à
/// regarder l'écran d'historique et son bandeau de statistiques tels qu'ils
/// seront, en remplaçant le seul port du domaine dont ils dépendent.
///
///     flutter run -d macos -t tool/preview.dart
library;

import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/model/reading_board.dart';
import 'package:bible/core/domain/model/reading_entry.dart';
import 'package:bible/core/domain/model/reading_history.dart';
import 'package:bible/core/domain/model/reading_plan.dart';
import 'package:bible/core/domain/model/reading_stats.dart';
import 'package:bible/core/domain/services/reading.repository.dart';
import 'package:bible/infrastructure/reading/providers/reading.repository_provider.dart';
import 'package:bible/ui/pages/dashboard/dashboard.page.dart';
import 'package:bible/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        readingRepositoryProvider.overrideWithValue(PreviewReadingRepository()),
      ],
      child: MaterialApp(
        title: 'Bible — aperçu',
        theme: AppThemeData.buildLightTheme(),
        darkTheme: AppThemeData.buildDarkTheme(),
        home: const DashboardPage(),
      ),
    ),
  );
}

/// Un plan en cours de lecture : 84 lectures derrière, 281 devant.
class PreviewReadingRepository implements ReadingRepository {
  static const _plan = ReadingPlan(
    id: 'plan-1',
    name: 'Plan chronologique',
    source: 'https://example.com/plan',
  );

  static const _passages = [
    'Genèse 1-3',
    'Genèse 4-7',
    'Genèse 8-11',
    'Genèse 12-15',
    'Genèse 16-18',
    'Genèse 19-21',
    'Job 1-5',
    'Job 6-9',
    'Exode 1-4',
    'Exode 5-8',
  ];

  static const _pageSize = 20;

  late List<ReadingEntry> _entries = [
    for (var i = 0; i < 6; i++)
      ReadingEntry(id: 'entry-$i', passages: _passages[i % _passages.length]),
  ];

  /// 84 lectures passées, une par jour, en remontant depuis hier.
  late List<ReadingHistoryEntry> _history = [
    for (var i = 0; i < 84; i++)
      ReadingHistoryEntry(
        id: 'read-$i',
        passages: _passages[i % _passages.length],
        readAt: DateTime.now().subtract(Duration(days: i + 1, hours: -8)),
      ),
  ];

  @override
  Future<ReadingBoard> loadBoard() async {
    await _latency();
    return ReadingBoard(plan: _plan, entries: _entries);
  }

  @override
  Future<ReadingBoard> markAsRead(String entryId) async {
    await _latency();
    final read = _entries.firstWhere((entry) => entry.id == entryId);
    _history = [
      ReadingHistoryEntry(
        id: read.id,
        passages: read.passages,
        readAt: DateTime.now(),
      ),
      ..._history,
    ];
    _entries = _entries.where((entry) => entry.id != entryId).toList();
    return ReadingBoard(plan: _plan, entries: _entries);
  }

  @override
  Future<ReadingBoard> markAsUnread(String entryId) async {
    await _latency();
    if (_history.isEmpty || _history.first.id != entryId) {
      throw const ReadingException(
        'Seule la dernière lecture validée peut repasser en non lue.',
      );
    }
    final restored = _history.first;
    _history = _history.sublist(1);
    _entries = [
      ReadingEntry(id: restored.id, passages: restored.passages),
      ..._entries,
    ];
    return ReadingBoard(plan: _plan, entries: _entries);
  }

  @override
  Future<ReadingHistory> loadHistory({int page = 1}) async {
    await _latency();
    final start = (page - 1) * _pageSize;
    final entries = _history.skip(start).take(_pageSize).toList();
    return ReadingHistory(
      entries: [
        for (final (index, entry) in entries.indexed)
          ReadingHistoryEntry(
            id: entry.id,
            passages: entry.passages,
            readAt: entry.readAt,
            canUnread: page == 1 && index == 0,
          ),
      ],
      page: page,
      hasMore: _history.length > start + entries.length,
    );
  }

  @override
  Future<ReadingStats> loadStats() async {
    await _latency();
    return ReadingStats(
      currentStreak: 5,
      longestStreak: 12,
      readCount: _history.length,
      planEntryCount: 365,
      firstReadAt: _history.isEmpty ? null : _history.last.readAt,
    );
  }

  /// Un peu d'attente, pour voir les indicateurs de chargement comme en vrai.
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 350));
}
