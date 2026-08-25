/// Les trois palettes de l'application, sur les vrais composants.
///
/// Hors de `lib/` : rien de ce fichier ne part dans l'application. Il sert à
/// comparer d'un coup d'œil ce que l'utilisateur peut choisir dans les
/// réglages, sans avoir à basculer le réglage trois fois.
///
///     flutter run -d macos -t tool/theme_gallery.dart
library;

import 'package:bible/core/application/dtos/reading_entry.dto.dart';
import 'package:bible/core/application/dtos/reading_history.dto.dart';
import 'package:bible/core/application/dtos/reading_stats.dto.dart';
import 'package:bible/core/domain/model/app_palette.dart';
import 'package:bible/ui/pages/dashboard/widgets/today_card.widget.dart';
import 'package:bible/ui/pages/dashboard/widgets/upcoming_row.widget.dart';
import 'package:bible/ui/pages/dashboard/widgets/stats_header.widget.dart';
import 'package:bible/ui/pages/history/widgets/history_entry_card.widget.dart';
import 'package:bible/ui/widgets/section_label.widget.dart';
import 'package:bible/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ThemeGalleryApp());

String labelOf(AppPalette palette) => switch (palette) {
  AppPalette.paper => 'Papier & encre',
  AppPalette.night => 'Nuit calme',
  AppPalette.mono => 'Monochrome',
};

String rationaleOf(AppPalette palette) => switch (palette) {
  AppPalette.paper => 'Ivoire chaud, encre profonde, accent terre cuite.',
  AppPalette.night => 'Ardoise profonde, accent bleu lumineux.',
  AppPalette.mono => 'Presque noir et blanc ; le vert ne sert qu\'à l\'action.',
};

class ThemeGalleryApp extends StatelessWidget {
  const ThemeGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible — directions de thème',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF8A8A8A),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            for (final palette in AppPalette.values) _PaletteBlock(palette),
          ],
        ),
      ),
    );
  }
}

/// Une palette : son intitulé, puis ses deux ambiances côte à côte.
class _PaletteBlock extends StatelessWidget {
  final AppPalette palette;

  const _PaletteBlock(this.palette);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelOf(palette),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          rationaleOf(palette),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Sample(theme: AppThemeData.buildLightTheme(palette))),
            const SizedBox(width: 24),
            Expanded(child: _Sample(theme: AppThemeData.buildDarkTheme(palette))),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

/// Les vrais composants de l'application, rendus dans une ambiance donnée.
class _Sample extends StatelessWidget {
  final ThemeData theme;

  const _Sample({required this.theme});

  static final _stats = ReadingStatsDto(
    currentStreak: 5,
    longestStreak: 12,
    readCount: 84,
    planEntryCount: 365,
    firstReadAt: DateTime(2026, 5, 1),
    progress: 84 / 365,
  );

  static const _today = ReadingEntryDto(
    id: 'entry-1',
    passages: 'Genèse 1-3',
    videos: [],
    canMarkAsRead: true,
  );

  static const _upcoming = ReadingEntryDto(
    id: 'entry-2',
    passages: 'Genèse 4-7',
    videos: [],
    canMarkAsRead: false,
  );

  static final _read = ReadingHistoryEntryDto(
    id: 'entry-0',
    passages: 'Introduction',
    readAt: DateTime(2026, 8, 24, 9, 12),
    canUnread: true,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AppBarSample(colorScheme: colorScheme),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatsHeader(
                      stats: _stats,
                      expanded: false,
                      onToggle: () {},
                    ),
                    StatsHeader(stats: _stats, expanded: true, onToggle: () {}),
                    const SizedBox(height: 8),
                    _SectionTitle('Lecture du jour'),
                    const SizedBox(height: 12),
                    TodayCard(entry: _today, onMarkAsRead: () {}),
                    _SectionTitle('Prochaines lectures'),
                    const SizedBox(height: 12),
                    const UpcomingRow(entry: _upcoming, rank: 1),
                    _SectionTitle('Historique'),
                    const SizedBox(height: 12),
                    HistoryEntryCard(entry: _read, onUndo: () {}),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        hintText: 'jean@example.com',
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Se connecter'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Créer un compte'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarSample extends StatelessWidget {
  final ColorScheme colorScheme;

  const _AppBarSample({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Plan chronologique',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Icon(Icons.history, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Icon(Icons.settings_outlined, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: SectionLabel(text),
    );
  }
}
