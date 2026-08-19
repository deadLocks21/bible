import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/model/user.dart';
import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/core/utils/backend_endpoints.dart';
import 'package:bible/infrastructure/http/api_error.dart';
import 'package:dio/dio.dart';

/// Implémentation HTTP de [AuthRepository] suivant `api/API.md` :
/// `POST /api/auth/login`, `/register`, `/logout`, `GET /api/me`.
///
/// Les erreurs sont traduites en [AuthException] à message lisible, à partir du
/// `code` machine de la réponse — jamais de son `error`, destiné à l'affichage
/// côté serveur et susceptible de changer.
class DioAuthRepository implements AuthRepository {
  final Dio _dio;

  /// Nom donné au jeton côté serveur, pour que la liste des appareils connectés
  /// reste lisible.
  final String deviceName;

  const DioAuthRepository(this._dio, {this.deviceName = 'mobile'});

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        BackendEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'device_name': deviceName,
        },
      );
      return _sessionFrom(response.data);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _signInMessages);
    }
  }

  @override
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        BackendEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': deviceName,
        },
      );
      return _sessionFrom(response.data);
    } on DioException catch (e) {
      throw _exceptionFrom(e, _signUpMessages);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dio.post<Map<String, dynamic>>(BackendEndpoints.logout);
    } on DioException catch (e) {
      throw _exceptionFrom(e, const {});
    }
  }

  @override
  Future<User> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        BackendEndpoints.me,
      );
      final user = response.data?['user'];
      if (user is! Map) {
        throw const AuthException('Réponse du serveur invalide.');
      }
      return _userFrom(user);
    } on DioException catch (e) {
      throw _exceptionFrom(e, const {});
    }
  }

  AuthSession _sessionFrom(Map<String, dynamic>? data) {
    final token = data?['token'];
    final user = data?['user'];
    if (token is! String || user is! Map) {
      throw const AuthException('Réponse du serveur invalide.');
    }
    return AuthSession(token: token, user: _userFrom(user));
  }

  User _userFrom(Map<dynamic, dynamic> json) {
    final id = json['id'];
    return User(
      // L'API renvoie l'identifiant en nombre ; on tolère la chaîne au cas où
      // un pilote de base le sérialiserait ainsi.
      id: id is int ? id : int.tryParse('$id') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  AuthException _exceptionFrom(
    DioException exception,
    Map<String, String> byCode,
  ) {
    final error = ApiError.from(exception);
    return AuthException(
      error.messageFrom(byCode),
      fieldErrors: error.fieldErrors,
    );
  }

  static const Map<String, String> _signInMessages = {
    'invalid_credentials': 'Adresse e-mail ou mot de passe incorrect.',
    'invalid_request': 'Vérifiez les informations saisies.',
    'rate_limited': 'Trop de tentatives. Réessayez dans quelques minutes.',
  };

  static const Map<String, String> _signUpMessages = {
    'invalid_request': 'Vérifiez les informations saisies.',
    'rate_limited': 'Trop de tentatives. Réessayez dans quelques minutes.',
  };
}
