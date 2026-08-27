import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/infrastructure/logger/in_memory.logger.service.dart';
import 'package:bible/ui/observability/logging.navigator_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggingNavigatorObserver', () {
    test('journalise l\'écran ouvert et celui d\'où l\'on vient', () {
      final logger = InMemoryLoggerService();
      final observer = LoggingNavigatorObserver(
        LoggerApplicationService(logger),
      );

      observer.didPush(
        _route(AppRoutes.settings),
        _route(AppRoutes.dashboard),
      );

      final record = logger.records.single;
      expect(record.message, 'ui.screen');
      expect(record.attributes['ui.action'], 'push');
      expect(record.attributes['ui.screen'], AppRoutes.settings);
      expect(record.attributes['ui.from'], AppRoutes.dashboard);
    });

    test('journalise la fermeture d\'un écran', () {
      final logger = InMemoryLoggerService();
      final observer = LoggingNavigatorObserver(
        LoggerApplicationService(logger),
      );

      observer.didPop(_route(AppRoutes.history), _route(AppRoutes.dashboard));

      expect(logger.records.single.attributes['ui.action'], 'pop');
      expect(logger.records.single.attributes['ui.screen'], AppRoutes.history);
    });

    test('renomme la route initiale de MaterialApp', () {
      final logger = InMemoryLoggerService();
      final observer = LoggingNavigatorObserver(
        LoggerApplicationService(logger),
      );

      observer.didPush(_route('/'), null);

      expect(logger.records.single.attributes['ui.screen'], AppRoutes.home);
      expect(logger.records.single.attributes.containsKey('ui.from'), isFalse);
    });

    test('ignore les routes anonymes — dialogues et feuilles modales', () {
      final logger = InMemoryLoggerService();
      final observer = LoggingNavigatorObserver(
        LoggerApplicationService(logger),
      );

      observer.didPush(_route(null), _route(AppRoutes.settings));

      expect(logger.records, isEmpty);
    });
  });
}

Route<void> _route(String? name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox.shrink(),
);
