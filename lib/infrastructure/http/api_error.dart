import 'package:dio/dio.dart';

/// Lecture normalisée d'une erreur renvoyée par l'API.
///
/// L'API répond `{ "error": <message>, "code": <code machine>, "errors": {…} }`
/// (cf. `api/API.md`). Les repositories s'appuient sur [code] — jamais sur le
/// message — pour choisir quoi afficher, et sur [fieldErrors] pour signaler les
/// champs fautifs dans les formulaires.
class ApiError {
  /// Code machine renvoyé par l'API, `null` quand la réponse n'en portait pas
  /// (panne réseau, 502 d'un reverse-proxy, corps non JSON…).
  final String? code;

  /// Erreurs de validation, un message par champ.
  final Map<String, String> fieldErrors;

  /// Vrai quand la requête n'a pas obtenu de réponse du tout : serveur
  /// injoignable, DNS, délai dépassé. Distingué du reste parce que le conseil à
  /// donner à l'utilisateur n'est pas le même (vérifier l'URL et le réseau).
  final bool isNetworkFailure;

  const ApiError({
    this.code,
    this.fieldErrors = const {},
    this.isNetworkFailure = false,
  });

  factory ApiError.from(DioException exception) {
    final response = exception.response;
    if (response == null) {
      return const ApiError(isNetworkFailure: true);
    }
    final data = response.data;
    if (data is! Map) {
      return const ApiError();
    }
    return ApiError(
      code: data['code'] as String?,
      fieldErrors: _readFieldErrors(data['errors']),
    );
  }

  /// Message à afficher : celui associé au [code] s'il est connu, sinon la
  /// première erreur de validation, sinon un message générique adapté à la
  /// nature de la panne.
  String messageFrom(
    Map<String, String> byCode, {
    String fallback = 'Une erreur est survenue. Réessayez.',
  }) {
    final known = code == null ? null : byCode[code];
    if (known != null) return known;
    if (fieldErrors.isNotEmpty) return fieldErrors.values.first;
    if (isNetworkFailure) {
      return 'Connexion au serveur impossible. '
          'Vérifiez l\'URL du serveur et votre réseau.';
    }
    return fallback;
  }

  /// `errors` de Laravel : `{"email": ["…", "…"]}`. Seul le premier message par
  /// champ est retenu — c'est tout ce qu'un formulaire affiche.
  static Map<String, String> _readFieldErrors(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, String>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      if (value is List && value.isNotEmpty && value.first is String) {
        result[key] = value.first as String;
      } else if (value is String) {
        result[key] = value;
      }
    });
    return result;
  }
}
