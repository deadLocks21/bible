import 'package:bible/core/application/dtos/reading_board.dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../builders/builders.dart';

void main() {
  group('ReadingBoard', () {
    test('la première lecture non lue est la lecture du jour', () {
      final board = aReadingBoard(
        entries: [
          aReadingEntry(id: 'entry-1', passages: 'Genèse 1-3'),
          aReadingEntry(id: 'entry-2', passages: 'Genèse 4-7'),
          aReadingEntry(id: 'entry-3', passages: 'Genèse 8-11'),
        ],
      );

      expect(board.today?.id, 'entry-1');
      expect(board.upcoming.map((e) => e.id), ['entry-2', 'entry-3']);
      expect(board.isCompleted, isFalse);
    });

    test('un plan sans lecture restante est terminé', () {
      final board = aReadingBoard(entries: []);

      expect(board.today, isNull);
      expect(board.upcoming, isEmpty);
      expect(board.isCompleted, isTrue);
    });

    test('une seule lecture restante n\'a aucune suivante', () {
      final board = aReadingBoard(entries: [aReadingEntry()]);

      expect(board.today, isNotNull);
      expect(board.upcoming, isEmpty);
    });
  });

  group('ReadingBoardDto', () {
    test('seule la lecture du jour est marquable comme lue', () {
      final dto = ReadingBoardDto.fromDomain(
        aReadingBoard(
          entries: [
            aReadingEntry(id: 'entry-1'),
            aReadingEntry(id: 'entry-2'),
          ],
        ),
      );

      expect(dto.today?.canMarkAsRead, isTrue);
      expect(dto.upcoming.single.canMarkAsRead, isFalse);
      expect(dto.isCompleted, isFalse);
    });

    test('compose le libellé de chaque chapitre', () {
      final dto = ReadingBoardDto.fromDomain(
        aReadingBoard(
          entries: [
            aReadingEntry(
              videos: [
                aChapterVideo(book: 'Genèse', chapter: 1),
                aChapterVideo(
                  youtubeVideoId: 'video-2',
                  book: 'Genèse',
                  chapter: 2,
                ),
              ],
            ),
          ],
        ),
      );

      expect(dto.today?.videos.map((v) => v.label), ['Genèse 1', 'Genèse 2']);
      expect(dto.today?.hasVideos, isTrue);
    });
  });
}
