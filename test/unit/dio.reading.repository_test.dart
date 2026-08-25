import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/infrastructure/reading/dio.reading.repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_dio.dart';

const _payload = {
  'plan': {
    'id': 'plan-1',
    'name': 'Plan chronologique',
    'source': 'https://example.com/plan',
  },
  'entries': [
    {
      'id': 'entry-1',
      'passages': 'Genèse 1-2',
      'videos': [
        {'id': 'video-1', 'book': 'Genèse', 'chapter': 1},
        {'id': 'video-2', 'book': 'Genèse', 'chapter': 2},
      ],
    },
    {'id': 'entry-2', 'passages': 'Genèse 3-5', 'videos': <Object>[]},
  ],
};

const _historyPayload = {
  'entries': [
    {
      'id': 'entry-1',
      'passages': 'Genèse 1-2',
      'read_at': '2026-08-24T09:12:00+00:00',
      'can_unread': true,
    },
    {
      'id': 'entry-0',
      'passages': 'Introduction',
      'read_at': '2026-08-23T09:12:00+00:00',
      'can_unread': false,
    },
  ],
  'page': 1,
  'has_more': true,
};

const _statsPayload = {
  'current_streak': 5,
  'longest_streak': 12,
  'read_count': 84,
  'plan_entry_count': 365,
  'first_read_at': '2026-05-01T07:12:00+00:00',
};

void main() {
  group('DioReadingRepository', () {
    test('décode le plan, les lectures et leurs vidéos', () async {
      final repository = DioReadingRepository(
        stubDio(handler: (_) => const StubResponse(200, _payload)),
      );

      final board = await repository.loadBoard();

      expect(board.plan.name, 'Plan chronologique');
      expect(board.entries, hasLength(2));
      expect(board.today?.passages, 'Genèse 1-2');
      expect(board.upcoming.single.passages, 'Genèse 3-5');
      expect(board.today?.videos.first.youtubeVideoId, 'video-1');
      expect(board.today?.videos.last.label, 'Genèse 2');
    });

    test('marque une lecture et renvoie le tableau rafraîchi', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioReadingRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, _payload),
        ),
      );

      final board = await repository.markAsRead('entry-1');

      expect(recorded.single.method, 'POST');
      expect(
        recorded.single.path,
        '/api/reading-plan/entries/entry-1/read',
      );
      expect(board.entries, hasLength(2));
    });

    test('repasse une lecture en non lue par un DELETE', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioReadingRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, _payload),
        ),
      );

      final board = await repository.markAsUnread('entry-1');

      expect(recorded.single.method, 'DELETE');
      expect(recorded.single.path, '/api/reading-plan/entries/entry-1/read');
      expect(board.entries, hasLength(2));
    });

    test('traduit not_last_read en message affichable', () async {
      final repository = DioReadingRepository(
        stubDio(
          handler: (_) => const StubResponse(409, {
            'error': 'pas la dernière',
            'code': 'not_last_read',
          }),
        ),
      );

      expect(
        repository.markAsUnread('entry-1'),
        throwsA(
          isA<ReadingException>().having(
            (e) => e.message,
            'message',
            'Seule la dernière lecture validée peut repasser en non lue.',
          ),
        ),
      );
    });

    test('décode une page d\'historique', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioReadingRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, _historyPayload),
        ),
      );

      final history = await repository.loadHistory(page: 2);

      expect(recorded.single.method, 'GET');
      expect(recorded.single.path, '/api/reading-plan/history');
      expect(recorded.single.query['page'], 2);
      expect(history.entries, hasLength(2));
      expect(history.entries.first.passages, 'Genèse 1-2');
      expect(history.entries.first.canUnread, isTrue);
      expect(
        history.entries.first.readAt.toUtc(),
        DateTime.utc(2026, 8, 24, 9, 12),
      );
      expect(history.entries.last.canUnread, isFalse);
      expect(history.hasMore, isTrue);
    });

    test('décode les statistiques de lecture', () async {
      final recorded = <RecordedRequest>[];
      final repository = DioReadingRepository(
        stubDio(
          recorded: recorded,
          handler: (_) => const StubResponse(200, _statsPayload),
        ),
      );

      final stats = await repository.loadStats();

      expect(recorded.single.path, '/api/reading-plan/stats');
      expect(stats.currentStreak, 5);
      expect(stats.longestStreak, 12);
      expect(stats.readCount, 84);
      expect(stats.planEntryCount, 365);
      expect(stats.firstReadAt?.toUtc(), DateTime.utc(2026, 5, 1, 7, 12));
      expect(stats.progress, closeTo(84 / 365, 0.0001));
    });

    test('accepte des statistiques sans première lecture', () async {
      final repository = DioReadingRepository(
        stubDio(
          handler: (_) => const StubResponse(200, {
            'current_streak': 0,
            'longest_streak': 0,
            'read_count': 0,
            'plan_entry_count': 0,
            'first_read_at': null,
          }),
        ),
      );

      final stats = await repository.loadStats();

      expect(stats.firstReadAt, isNull);
      expect(stats.isEmpty, isTrue);
      // Pas de dénominateur : la progression vaut zéro plutôt que `NaN`.
      expect(stats.progress, 0);
    });

    test('signale l\'absence de plan actif par une exception dédiée', () async {
      final repository = DioReadingRepository(
        stubDio(
          handler: (_) => const StubResponse(404, {
            'error': 'Aucun plan de lecture actif.',
            'code': 'no_active_plan',
          }),
        ),
      );

      expect(repository.loadBoard(), throwsA(isA<NoActivePlanException>()));
    });

    test('traduit already_read en message affichable', () async {
      final repository = DioReadingRepository(
        stubDio(
          handler: (_) => const StubResponse(409, {
            'error': 'déjà lue',
            'code': 'already_read',
          }),
        ),
      );

      expect(
        () => repository.markAsRead('entry-1'),
        throwsA(
          isA<ReadingException>().having(
            (e) => e.message,
            'message',
            'Cette lecture est déjà marquée comme lue.',
          ),
        ),
      );
    });
  });
}
