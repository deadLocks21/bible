import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/model/reading_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/fake_repositories.dart';
import '../utils/pumps.dart';

void main() {
  group('Tableau de bord', () {
    testWidgets('affiche la régularité en tête', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: [aReadingHistoryEntry(passages: 'Introduction')],
          stats: const ReadingStats(
            currentStreak: 5,
            longestStreak: 12,
            readCount: 84,
            planEntryCount: 365,
          ),
        ),
      );

      // Replié par défaut : une ligne, pas le bandeau complet.
      expect(find.byKey(const Key('dashboardStats')), findsOneWidget);
      expect(find.text('5 jours d\'affilée · 23 % du plan'), findsOneWidget);
      expect(find.text('SÉRIE EN COURS'), findsNothing);
    });

    testWidgets('déplie la régularité et retient le choix', (tester) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: [aReadingHistoryEntry(passages: 'Introduction')],
          stats: const ReadingStats(
            currentStreak: 5,
            longestStreak: 12,
            readCount: 84,
            planEntryCount: 365,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('dashboardStatsToggle')));
      await tester.pumpAndSettle();

      expect(find.text('SÉRIE EN COURS'), findsOneWidget);
      expect(find.text('5 jours'), findsOneWidget);
      expect(find.text('12 jours'), findsOneWidget);
      expect(find.text('AVANCEMENT'), findsOneWidget);
      expect(find.text('84 lectures sur 365 — 23 %'), findsOneWidget);
      expect(app.dashboardPreferences.statsExpanded, isTrue);
    });

    testWidgets('rouvre déplié quand l\'utilisateur l\'avait laissé ainsi', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: [aReadingHistoryEntry(passages: 'Introduction')],
          stats: const ReadingStats(
            currentStreak: 5,
            longestStreak: 12,
            readCount: 84,
            planEntryCount: 365,
          ),
        ),
        dashboardPreferences: FakeDashboardPreferencesRepository(
          statsExpanded: true,
        ),
      );

      expect(find.text('SÉRIE EN COURS'), findsOneWidget);
    });

    testWidgets('masque le bandeau tant que rien n\'a été lu', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );

      expect(find.byKey(const Key('dashboardStats')), findsNothing);
    });

    testWidgets('affiche le plan, la lecture du jour et les suivantes', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(
            entries: [
              aReadingEntry(id: 'entry-1', passages: 'Genèse 1-3'),
              aReadingEntry(id: 'entry-2', passages: 'Genèse 4-7'),
              aReadingEntry(id: 'entry-3', passages: 'Genèse 8-11'),
            ],
          ),
        ),
      );

      expect(find.text('Plan chronologique'), findsOneWidget);
      expect(find.text('Lecture du jour'), findsOneWidget);
      expect(find.text('Genèse 1-3'), findsOneWidget);
      expect(find.text('Prochaines lectures'), findsOneWidget);
      expect(find.text('Genèse 4-7'), findsOneWidget);
      expect(find.text('Genèse 8-11'), findsOneWidget);
    });

    testWidgets(
      'seule la lecture du jour peut être marquée comme lue',
      (tester) async {
        await pumpApp(
          tester,
          session: anAuthSession(),
          reading: FakeReadingRepository(board: aReadingBoard()),
        );

        expect(find.byKey(const Key('markAsReadButton')), findsOneWidget);
      },
    );

    testWidgets('marquer comme lu fait avancer le plan', (tester) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );

      await tester.tap(find.byKey(const Key('markAsReadButton')));
      await tester.pumpAndSettle();

      expect(app.reading.readEntries, ['entry-1']);
      expect(find.text('Genèse 1-3'), findsNothing);
      // La lecture suivante prend la place de la lecture du jour.
      expect(find.text('Lecture du jour'), findsOneWidget);
      expect(find.text('Genèse 4-7'), findsOneWidget);
    });

    testWidgets('signale un échec sans faire disparaître les lectures', (
      tester,
    ) async {
      final reading = FakeReadingRepository(board: aReadingBoard());
      await pumpApp(tester, session: anAuthSession(), reading: reading);

      // La lecture disparaît côté serveur entre l'affichage et le clic.
      reading.board = null;
      reading.failure = const ReadingException('Serveur injoignable.');

      await tester.tap(find.byKey(const Key('markAsReadButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboardError')), findsOneWidget);
      expect(find.text('Genèse 1-3'), findsOneWidget);
    });

    testWidgets('explique l\'absence de plan actif sans parler d\'erreur', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          failure: const NoActivePlanException(
            'Aucun plan de lecture ne vous est encore assigné.',
          ),
        ),
      );

      expect(find.byKey(const Key('dashboardNoPlanState')), findsOneWidget);
      expect(
        find.text('Aucun plan de lecture ne vous est encore assigné.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dashboardRetryButton')), findsNothing);
    });

    testWidgets('propose de réessayer après un échec de chargement', (
      tester,
    ) async {
      final reading = FakeReadingRepository(
        failure: const ReadingException('Serveur injoignable.'),
      );
      await pumpApp(tester, session: anAuthSession(), reading: reading);

      expect(find.byKey(const Key('dashboardErrorState')), findsOneWidget);

      reading.board = aReadingBoard();
      await tester.tap(find.byKey(const Key('dashboardRetryButton')));
      await tester.pumpAndSettle();

      expect(find.text('Genèse 1-3'), findsOneWidget);
    });

    testWidgets('annonce un plan terminé quand il ne reste rien à lire', (
      tester,
    ) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard(entries: [])),
      );

      expect(find.byKey(const Key('dashboardCompletedState')), findsOneWidget);
    });
  });
}
