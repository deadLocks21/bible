import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/model/bible_chapter_video.dart';
import 'package:bible/core/domain/model/reading_board.dart';
import 'package:bible/core/domain/model/reading_entry.dart';
import 'package:bible/core/domain/model/reading_history.dart';
import 'package:bible/core/domain/model/reading_plan.dart';
import 'package:bible/core/domain/services/reading.repository.dart';
import 'package:bible/core/utils/backend_endpoints.dart';
import 'package:bible/infrastructure/http/api_error.dart';
import 'package:dio/dio.dart';

/// Implémentation HTTP de [ReadingRepository] suivant `api/API.md` :
/// `GET /api/reading-plan`, `POST`/`DELETE
/// /api/reading-plan/entries/{id}/read` et `GET /api/reading-plan/history`.
///
/// Les trois endpoints du tableau de bord répondent la même charge utile, d'où
/// le décodage partagé.
class DioReadingRepository implements ReadingRepository {
  final Dio _dio;

  const DioReadingRepository(this._dio);

  @override
  Future<ReadingBoard> loadBoard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        BackendEndpoints.readingPlan,
      );
      return _boardFrom(response.data);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _loadMessages);
    }
  }

  @override
  Future<ReadingBoard> markAsRead(String entryId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        BackendEndpoints.readEntry(entryId),
      );
      return _boardFrom(response.data);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _markMessages);
    }
  }

  @override
  Future<ReadingBoard> markAsUnread(String entryId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        BackendEndpoints.readEntry(entryId),
      );
      return _boardFrom(response.data);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _unreadMessages);
    }
  }

  @override
  Future<ReadingHistory> loadHistory({int page = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        BackendEndpoints.readingHistory,
        queryParameters: {'page': page},
      );
      return _historyFrom(response.data, page);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _loadMessages);
    }
  }

  ReadingHistory _historyFrom(Map<String, dynamic>? data, int requestedPage) {
    final entries = data?['entries'];
    if (entries is! List) {
      throw const ReadingException('Réponse du serveur invalide.');
    }
    final page = data?['page'];
    return ReadingHistory(
      entries: entries.whereType<Map>().map(_historyEntryFrom).toList(),
      page: page is int ? page : requestedPage,
      hasMore: data?['has_more'] == true,
    );
  }

  ReadingHistoryEntry _historyEntryFrom(Map<dynamic, dynamic> json) {
    final readAt = DateTime.tryParse('${json['read_at']}');
    if (readAt == null) {
      throw const ReadingException('Réponse du serveur invalide.');
    }
    return ReadingHistoryEntry(
      id: json['id'] as String? ?? '',
      passages: json['passages'] as String? ?? '',
      readAt: readAt.toLocal(),
      canUnread: json['can_unread'] == true,
    );
  }

  ReadingBoard _boardFrom(Map<String, dynamic>? data) {
    final plan = data?['plan'];
    final entries = data?['entries'];
    if (plan is! Map || entries is! List) {
      throw const ReadingException('Réponse du serveur invalide.');
    }
    return ReadingBoard(
      plan: ReadingPlan(
        id: plan['id'] as String? ?? '',
        name: plan['name'] as String? ?? '',
        source: plan['source'] as String? ?? '',
      ),
      entries: entries.whereType<Map>().map(_entryFrom).toList(),
    );
  }

  ReadingEntry _entryFrom(Map<dynamic, dynamic> json) {
    final videos = json['videos'];
    return ReadingEntry(
      id: json['id'] as String? ?? '',
      passages: json['passages'] as String? ?? '',
      videos: videos is List
          ? videos.whereType<Map>().map(_videoFrom).toList()
          : const [],
    );
  }

  BibleChapterVideo _videoFrom(Map<dynamic, dynamic> json) {
    final chapter = json['chapter'];
    return BibleChapterVideo(
      // `id` porte ici l'identifiant YouTube, pas celui de la ligne en base :
      // c'est la forme renvoyée par l'API, alignée sur les props Inertia du web.
      youtubeVideoId: json['id'] as String? ?? '',
      book: json['book'] as String? ?? '',
      chapter: chapter is int ? chapter : int.tryParse('$chapter') ?? 0,
    );
  }

  ReadingException _exceptionFrom(
    DioException exception,
    Map<String, String> byCode,
  ) {
    final error = ApiError.from(exception);
    if (error.code == 'no_active_plan') {
      return NoActivePlanException(error.messageFrom(byCode));
    }
    return ReadingException(error.messageFrom(byCode));
  }

  static const Map<String, String> _loadMessages = {
    'no_active_plan': 'Aucun plan de lecture ne vous est encore assigné.',
  };

  static const Map<String, String> _unreadMessages = {
    'no_active_plan': 'Aucun plan de lecture ne vous est encore assigné.',
    'entry_not_in_plan':
        'Cette lecture ne fait pas partie de votre plan actif.',
    'not_read': 'Cette lecture n\'est pas marquée comme lue.',
    'not_last_read':
        'Seule la dernière lecture validée peut repasser en non lue.',
  };

  static const Map<String, String> _markMessages = {
    'no_active_plan': 'Aucun plan de lecture ne vous est encore assigné.',
    'entry_not_in_plan':
        'Cette lecture ne fait pas partie de votre plan actif.',
    'already_read': 'Cette lecture est déjà marquée comme lue.',
  };
}
