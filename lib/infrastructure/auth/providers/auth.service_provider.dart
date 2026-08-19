import 'package:bible/core/application/services/auth_application.service.dart';
import 'package:bible/core/application/usecases/restore_session.usecase.dart';
import 'package:bible/core/application/usecases/sign_in.usecase.dart';
import 'package:bible/core/application/usecases/sign_out.usecase.dart';
import 'package:bible/core/application/usecases/sign_up.usecase.dart';
import 'package:bible/infrastructure/auth/providers/auth.repository_provider.dart';
import 'package:bible/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.service_provider.g.dart';

@riverpod
AuthApplicationService authService(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  final tokenStore = ref.watch(authTokenStoreProvider);
  final logger = ref.watch(loggerProvider);
  return AuthApplicationService(
    signIn: SignInUseCase(auth, tokenStore, logger),
    signUp: SignUpUseCase(auth, tokenStore, logger),
    signOut: SignOutUseCase(auth, tokenStore, logger),
    restoreSession: RestoreSessionUseCase(tokenStore, logger),
  );
}
