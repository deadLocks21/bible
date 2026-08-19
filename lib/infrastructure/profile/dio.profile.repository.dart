import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/model/user.dart';
import 'package:bible/core/domain/services/profile.repository.dart';
import 'package:bible/core/utils/backend_endpoints.dart';
import 'package:bible/infrastructure/http/api_error.dart';
import 'package:dio/dio.dart';

/// Implémentation HTTP de [ProfileRepository] suivant `api/API.md` :
/// `PATCH /api/profile`, `PUT /api/profile/password`, `DELETE /api/profile`.
class DioProfileRepository implements ProfileRepository {
  final Dio _dio;

  const DioProfileRepository(this._dio);

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        BackendEndpoints.profile,
        data: {'name': name, 'email': email},
      );
      final user = response.data?['user'];
      if (user is! Map) {
        throw const ProfileException('Réponse du serveur invalide.');
      }
      final id = user['id'];
      return User(
        id: id is int ? id : int.tryParse('$id') ?? 0,
        name: user['name'] as String? ?? name,
        email: user['email'] as String? ?? email,
      );
    } on DioException catch (e) {
      throw _exceptionFrom(e, _updateMessages);
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        BackendEndpoints.profilePassword,
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw _exceptionFrom(e, _passwordMessages);
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        BackendEndpoints.profile,
        data: {'password': password},
      );
    } on DioException catch (e) {
      throw _exceptionFrom(e, _deleteMessages);
    }
  }

  ProfileException _exceptionFrom(
    DioException exception,
    Map<String, String> byCode,
  ) {
    final error = ApiError.from(exception);
    return ProfileException(
      error.messageFrom(byCode),
      fieldErrors: error.fieldErrors,
    );
  }

  static const Map<String, String> _updateMessages = {
    'invalid_request': 'Vérifiez les informations saisies.',
  };

  // `invalid_request` couvre ici le mot de passe actuel erroné : la règle
  // `current_password` de Laravel remonte en erreur de validation, sur le champ
  // `current_password`, et le message précis vient donc de `fieldErrors`.
  static const Map<String, String> _passwordMessages = {};

  static const Map<String, String> _deleteMessages = {};
}
