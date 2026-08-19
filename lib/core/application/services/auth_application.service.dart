import 'package:bible/core/application/usecases/restore_session.usecase.dart';
import 'package:bible/core/application/usecases/sign_in.usecase.dart';
import 'package:bible/core/application/usecases/sign_out.usecase.dart';
import 'package:bible/core/application/usecases/sign_up.usecase.dart';

/// Regroupe les cas d'usage d'authentification, consommés par le notifier
/// d'état d'authentification de l'UI.
class AuthApplicationService {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final RestoreSessionUseCase restoreSession;

  const AuthApplicationService({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.restoreSession,
  });
}
