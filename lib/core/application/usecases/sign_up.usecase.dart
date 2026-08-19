import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';

/// Issue de [SignUpUseCase.execute].
sealed class SignUpResult {
  const SignUpResult();
}

class SignUpSuccess extends SignUpResult {
  final AuthSession session;

  const SignUpSuccess(this.session);
}

class SignUpFailure extends SignUpResult {
  final String message;
  final Map<String, String> fieldErrors;

  const SignUpFailure(this.message, {this.fieldErrors = const {}});
}

/// Création de compte. Le serveur connecte l'utilisateur dans la foulée, comme
/// le formulaire web : la session est donc persistée immédiatement.
class SignUpUseCase {
  final AuthRepository _auth;
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const SignUpUseCase(this._auth, this._tokenStore, this._logger);

  Future<SignUpResult> execute({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Vérification locale avant l'aller-retour : le serveur la refait, mais
    // l'utilisateur n'a pas à attendre le réseau pour une faute de frappe.
    if (password != passwordConfirmation) {
      return const SignUpFailure(
        'Les mots de passe ne correspondent pas.',
        fieldErrors: {
          'password_confirmation': 'Les mots de passe ne correspondent pas.',
        },
      );
    }
    try {
      final session = await _auth.signUp(
        name: name.trim(),
        email: email.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _tokenStore.write(session);
      await _logger.info('auth.signed_up');
      return SignUpSuccess(session);
    } on AuthException catch (e, stack) {
      await _logger.warn('auth.sign_up_failed', error: e, stack: stack);
      return SignUpFailure(e.message, fieldErrors: e.fieldErrors);
    } catch (e, stack) {
      await _logger.error('auth.sign_up_failed', error: e, stack: stack);
      return const SignUpFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
