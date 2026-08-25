import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:bible/core/domain/model/app_theme_mode.dart';
import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/exceptions/reading.exception.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/model/reading_board.dart';
import 'package:bible/core/domain/model/reading_entry.dart';
import 'package:bible/core/domain/model/reading_history.dart';
import 'package:bible/core/domain/model/user.dart';
import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/core/domain/services/profile.repository.dart';
import 'package:bible/core/domain/services/reading.repository.dart';
import 'package:bible/core/domain/services/theme.repository.dart';

import '../../builders/builders.dart';

/// Implémentations de test des ports du domaine.
///
/// C'est le bénéfice direct de l'architecture : les écrans se testent en
/// remplaçant les adaptateurs, sans faux serveur HTTP ni implémentation en
/// mémoire embarquée dans l'application.

class FakeAuthRepository implements AuthRepository {
  /// Session renvoyée par [signIn] / [signUp]. Quand elle est `null`, l'appel
  /// échoue avec [failure].
  AuthSession? session;
  AuthException failure;

  int signOutCalls = 0;

  FakeAuthRepository({
    this.session,
    this.failure = const AuthException('Identifiants incorrects.'),
  });

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final result = session;
    if (result == null) throw failure;
    return result;
  }

  @override
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = session;
    if (result == null) throw failure;
    return result;
  }

  @override
  Future<void> signOut() async => signOutCalls++;

  @override
  Future<User> me() async => (session ?? anAuthSession()).user;
}

class FakeReadingRepository implements ReadingRepository {
  /// Tableau renvoyé par [loadBoard]. `null` déclenche [failure].
  ReadingBoard? board;
  ReadingException failure;

  final List<String> readEntries = [];
  final List<String> unreadEntries = [];

  /// Lectures déjà validées, de la plus récente à la plus ancienne, comme les
  /// sert l'API.
  final List<ReadingHistoryEntry> history;

  /// Taille d'une page d'historique, calquée sur celle du serveur.
  static const int historyPageSize = 20;

  FakeReadingRepository({
    this.board,
    this.failure = const NoActivePlanException(
      'Aucun plan de lecture ne vous est encore assigné.',
    ),
    List<ReadingHistoryEntry>? history,
  }) : history = [...?history];

  @override
  Future<ReadingBoard> loadBoard() async {
    final result = board;
    if (result == null) throw failure;
    return result;
  }

  @override
  Future<ReadingBoard> markAsRead(String entryId) async {
    readEntries.add(entryId);
    final current = board;
    if (current == null) throw failure;
    // Le serveur renvoie le tableau rafraîchi : on retire la lecture marquée.
    final read = current.entries.firstWhere((entry) => entry.id == entryId);
    history.insert(
      0,
      ReadingHistoryEntry(
        id: read.id,
        passages: read.passages,
        readAt: DateTime(2026, 8, 24, 9, 12),
      ),
    );
    board = ReadingBoard(
      plan: current.plan,
      entries: current.entries.where((entry) => entry.id != entryId).toList(),
    );
    return board!;
  }

  @override
  Future<ReadingBoard> markAsUnread(String entryId) async {
    unreadEntries.add(entryId);
    final current = board;
    if (current == null) throw failure;
    if (history.isEmpty || history.first.id != entryId) {
      throw const ReadingException(
        'Seule la dernière lecture validée peut repasser en non lue.',
      );
    }
    // Comme le serveur : la lecture retourne en tête du plan, et le tableau
    // rafraîchi est renvoyé.
    final restored = history.removeAt(0);
    board = ReadingBoard(
      plan: current.plan,
      entries: [
        ReadingEntry(id: restored.id, passages: restored.passages),
        ...current.entries,
      ],
    );
    return board!;
  }

  @override
  Future<ReadingHistory> loadHistory({int page = 1}) async {
    if (board == null) throw failure;
    final start = (page - 1) * historyPageSize;
    final pageEntries = history.skip(start).take(historyPageSize).toList();
    return ReadingHistory(
      entries: [
        for (final (index, entry) in pageEntries.indexed)
          ReadingHistoryEntry(
            id: entry.id,
            passages: entry.passages,
            readAt: entry.readAt,
            // Seule la lecture la plus récente est défaisable.
            canUnread: page == 1 && index == 0,
          ),
      ],
      page: page,
      hasMore: history.length > start + pageEntries.length,
    );
  }
}

class FakeProfileRepository implements ProfileRepository {
  ProfileException? failure;

  User? updatedUser;
  String? deletedWithPassword;

  FakeProfileRepository({this.failure});

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    final error = failure;
    if (error != null) throw error;
    return updatedUser = aUser(name: name, email: email);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final error = failure;
    if (error != null) throw error;
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final error = failure;
    if (error != null) throw error;
    deletedWithPassword = password;
  }
}

class FakeThemeRepository implements ThemeRepository {
  AppThemeMode mode;

  FakeThemeRepository({this.mode = AppThemeMode.system});

  @override
  Future<AppThemeMode> getThemeMode() async => mode;

  @override
  Future<void> setThemeMode(AppThemeMode value) async => mode = value;
}
