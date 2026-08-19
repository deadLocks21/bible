import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Une réponse préparée pour [stubDio].
class StubResponse {
  final int statusCode;
  final Object? body;

  const StubResponse(this.statusCode, [this.body]);
}

/// Requête telle qu'elle est partie, pour que les tests puissent vérifier la
/// méthode, le chemin, les en-têtes et la charge utile envoyés.
class RecordedRequest {
  final String method;
  final String path;
  final Object? data;
  final Map<String, dynamic> headers;

  const RecordedRequest({
    required this.method,
    required this.path,
    required this.data,
    required this.headers,
  });
}

/// Construit un [Dio] dont les appels ne partent jamais sur le réseau : chaque
/// requête est enregistrée dans [recorded] et servie par [handler].
///
/// Utilisé pour tester les `dio.*.repository.dart` sur ce qui les concerne :
/// le format d'échange avec l'API (chemins, corps, traduction des erreurs).
Dio stubDio({
  required StubResponse Function(RequestOptions options) handler,
  List<RecordedRequest>? recorded,
  String baseUrl = 'https://bible.test',
}) {
  final dio = Dio(
    BaseOptions(baseUrl: baseUrl, headers: {'Accept': 'application/json'}),
  );
  dio.httpClientAdapter = _StubAdapter(handler, recorded ?? []);
  return dio;
}

class _StubAdapter implements HttpClientAdapter {
  final StubResponse Function(RequestOptions options) _handler;
  final List<RecordedRequest> _recorded;

  _StubAdapter(this._handler, this._recorded);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _recorded.add(
      RecordedRequest(
        method: options.method,
        path: options.uri.path,
        data: options.data,
        headers: options.headers,
      ),
    );
    final response = _handler(options);
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
