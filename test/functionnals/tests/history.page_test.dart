import 'package:bible/core/domain/model/reading_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/fake_repositories.dart';
import '../utils/pumps.dart';

/// Ouvre l'historique depuis le tableau de bord, comme l'utilisateur.
Future<void> openHistory(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('dashboardHistoryButton')));
  await tester.pumpAndSettle();
}

void main() {
  group('Historique', () {
    testWidgets('liste ce qui a été lu et quand', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: [
            aReadingHistoryEntry(id: 'entry-0', passages: 'Introduction'),
            aReadingHistoryEntry(
              id: 'entry-old',
              passages: 'Préface',
              readAt: DateTime(2026, 8, 23, 20, 5),
            ),
          ],
        ),
      );

      await openHistory(tester);

      expect(find.byKey(const Key('historyTitle')), findsOneWidget);
      expect(find.text('Introduction'), findsOneWidget);
      expect(find.text('Lu le 24 août 2026 à 09:12'), findsOneWidget);
      expect(find.text('Préface'), findsOneWidget);
      expect(find.text('Lu le 23 août 2026 à 20:05'), findsOneWidget);
    });

    testWidgets('annonce un historique vide', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(board: aReadingBoard()),
      );

      await openHistory(tester);

      expect(find.byKey(const Key('historyEmptyState')), findsOneWidget);
    });

    testWidgets(
      'seule la lecture la plus récente peut repasser en non lue',
      (tester) async {
        await pumpApp(
          tester,
          session: anAuthSession(),
          reading: FakeReadingRepository(
            board: aReadingBoard(),
            history: [
              aReadingHistoryEntry(id: 'entry-0', passages: 'Introduction'),
              aReadingHistoryEntry(id: 'entry-old', passages: 'Préface'),
            ],
          ),
        );

        await openHistory(tester);

        expect(find.byKey(const Key('markAsUnreadButton')), findsOneWidget);
      },
    );

    testWidgets('repasser en non lu rend la lecture au plan', (tester) async {
      final app = await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: [
            aReadingHistoryEntry(id: 'entry-0', passages: 'Introduction'),
          ],
        ),
      );

      await openHistory(tester);
      await tester.tap(find.byKey(const Key('markAsUnreadButton')));
      await tester.pumpAndSettle();

      expect(app.reading.unreadEntries, ['entry-0']);
      // La lecture quitte l'historique…
      expect(find.byKey(const Key('historyEmptyState')), findsOneWidget);

      // …et redevient la lecture du jour sur le tableau de bord.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Lecture du jour'), findsOneWidget);
      expect(find.text('Introduction'), findsOneWidget);
    });

    testWidgets('signale un échec sans vider la liste', (tester) async {
      final reading = FakeReadingRepository(
        board: aReadingBoard(),
        history: [aReadingHistoryEntry(passages: 'Introduction')],
      );
      await pumpApp(tester, session: anAuthSession(), reading: reading);

      await openHistory(tester);
      // Une lecture plus récente est arrivée entre-temps : le serveur refuse.
      reading.history.insert(
        0,
        aReadingHistoryEntry(id: 'entry-9', passages: 'Genèse 12-15'),
      );

      await tester.tap(find.byKey(const Key('markAsUnreadButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('historyError')), findsOneWidget);
      expect(find.text('Introduction'), findsOneWidget);
    });

    testWidgets('charge la page suivante en défilant', (tester) async {
      await pumpApp(
        tester,
        session: anAuthSession(),
        reading: FakeReadingRepository(
          board: aReadingBoard(),
          history: <ReadingHistoryEntry>[
            for (var i = 0; i < 25; i++)
              aReadingHistoryEntry(id: 'entry-$i', passages: 'Lecture $i'),
          ],
        ),
      );

      await openHistory(tester);

      expect(find.text('Lecture 0'), findsOneWidget);
      expect(find.text('Lecture 24'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();

      expect(find.text('Lecture 24'), findsOneWidget);
    });
  });
}
