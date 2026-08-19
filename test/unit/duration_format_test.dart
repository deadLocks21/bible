import 'package:bible/ui/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPlaybackDuration', () {
    test('omet les heures tant que la durée reste courte', () {
      expect(formatPlaybackDuration(Duration.zero), '0:00');
      expect(formatPlaybackDuration(const Duration(seconds: 7)), '0:07');
      expect(formatPlaybackDuration(const Duration(minutes: 12, seconds: 5)), '12:05');
    });

    test('affiche les heures dès qu\'il y en a', () {
      expect(
        formatPlaybackDuration(const Duration(hours: 1, minutes: 4, seconds: 9)),
        '1:04:09',
      );
    });

    test('ramène une durée négative à zéro', () {
      expect(formatPlaybackDuration(const Duration(seconds: -3)), '0:00');
    });
  });
}
