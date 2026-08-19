import 'package:bible/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:bible/infrastructure/auth/providers/session_revocation.provider.dart';
import 'package:bible/infrastructure/http/auth.interceptor.dart';
import 'package:bible/infrastructure/http/providers/api_base_url.provider.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.provider.g.dart';

/// Client HTTP partagé par tous les `dio.*.repository.dart`.
///
/// L'`baseUrl` vient d'[apiBaseUrlProvider] : changer de serveur depuis les
/// réglages reconstruit ce provider, donc une nouvelle instance visant la
/// nouvelle origine (au prix du pool de connexions, négligeable pour un
/// changement aussi rare).
///
/// Des délais explicites sont indispensables : sans eux, un serveur injoignable
/// dont la connexion TCP reste ouverte sans répondre bloquerait l'écran
/// indéfiniment, au lieu de remonter une erreur affichable.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider),
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // Laravel ne renvoie du JSON — y compris pour ses erreurs de validation —
      // que si le client l'annonce ; sans cet en-tête il répondrait une
      // redirection HTML.
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      ref.watch(authTokenStoreProvider),
      () => ref.read(sessionRevocationProvider.notifier).signal(),
      ref.watch(loggerProvider),
    ),
  );

  return dio;
}
