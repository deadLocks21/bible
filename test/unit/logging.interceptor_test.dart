import 'dart:typed_data';

import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/model/log_level.dart';
import 'package:bible/infrastructure/http/logging.interceptor.dart';
import 'package:bible/infrastructure/logger/in_memory.logger.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/stub_dio.dart';

void main() {
  group('LoggingInterceptor', () {
    test('journalise un appel abouti en debug, avec sa durée', () async {
      final logger = InMemoryLoggerService();
      final dio = _dioWith(
        logger,
        handler: (_) => const StubResponse(200, {'plan': {}}),
      );

      await dio.get<Map<String, dynamic>>('/api/reading-plan');

      final record = logger.records.single;
      expect(record.level, LogLevel.debug);
      expect(record.message, 'http.call');
      expect(record.attributes['http.method'], 'GET');
      expect(record.attributes['http.path'], '/api/reading-plan');
      expect(record.attributes['http.status'], 200);
      expect(record.attributes['duration_ms'], isA<int>());
    });

    test('journalise un 4xx en warn, avec le code machine de l\'API', () async {
      final logger = InMemoryLoggerService();
      final dio = _dioWith(
        logger,
        handler: (_) => const StubResponse(401, {
          'error': 'Identifiants incorrects.',
          'code': 'invalid_credentials',
        }),
      );

      await expectLater(
        dio.post<Map<String, dynamic>>('/api/auth/login'),
        throwsA(isA<DioException>()),
      );

      final record = logger.records.single;
      expect(record.level, LogLevel.warn);
      expect(record.message, 'http.failed');
      expect(record.attributes['http.status'], 401);
      expect(record.attributes['api.code'], 'invalid_credentials');
    });

    test('journalise un 5xx en error', () async {
      final logger = InMemoryLoggerService();
      final dio = _dioWith(logger, handler: (_) => const StubResponse(503));

      await expectLater(
        dio.get<Map<String, dynamic>>('/api/reading-plan'),
        throwsA(isA<DioException>()),
      );

      final record = logger.records.single;
      expect(record.level, LogLevel.error);
      expect(record.message, 'http.failed');
      expect(record.attributes['http.status'], 503);
    });

    test('journalise un serveur injoignable en error, avec le type Dio', () async {
      final logger = InMemoryLoggerService();
      final dio = Dio(BaseOptions(baseUrl: 'https://bible.test'))
        ..httpClientAdapter = _UnreachableAdapter()
        ..interceptors.add(
          LoggingInterceptor(LoggerApplicationService(logger)),
        );

      await expectLater(
        dio.get<Map<String, dynamic>>('/api/reading-plan'),
        throwsA(isA<DioException>()),
      );

      final record = logger.records.single;
      expect(record.level, LogLevel.error);
      expect(record.message, 'http.failed');
      expect(record.attributes['http.error_type'], 'connectionError');
      // Pas de réponse : rien à journaliser comme statut.
      expect(record.attributes.containsKey('http.status'), isFalse);
    });

    test('ne journalise ni le corps envoyé ni les en-têtes', () async {
      final logger = InMemoryLoggerService();
      final dio = _dioWith(
        logger,
        handler: (_) => const StubResponse(200, {'token': 'jeton-secret'}),
      );

      await dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': 'jean@example.com', 'password': 'motdepasse'},
        options: Options(headers: {'Authorization': 'Bearer jeton-secret'}),
      );

      final journalise = logger.records.single.attributes.values.join(' ');
      expect(journalise, isNot(contains('motdepasse')));
      expect(journalise, isNot(contains('jeton-secret')));
      expect(journalise, isNot(contains('jean@example.com')));
    });

    test('ne journalise pas les paramètres de requête', () async {
      final logger = InMemoryLoggerService();
      final dio = _dioWith(
        logger,
        handler: (_) => const StubResponse(200, {'entries': []}),
      );

      await dio.get<Map<String, dynamic>>(
        '/api/reading-plan/history',
        queryParameters: {'page': 3},
      );

      expect(
        logger.records.single.attributes['http.path'],
        '/api/reading-plan/history',
      );
    });
  });
}

Dio _dioWith(
  InMemoryLoggerService logger, {
  required StubResponse Function(RequestOptions options) handler,
}) {
  final dio = stubDio(handler: handler);
  dio.interceptors.add(LoggingInterceptor(LoggerApplicationService(logger)));
  return dio;
}

/// Adaptateur qui échoue comme le ferait un serveur injoignable : pas de
/// réponse du tout, donc pas de statut à lire.
class _UnreachableAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'hôte introuvable',
    );
  }

  @override
  void close({bool force = false}) {}
}
