import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/auth.exception.dart';
import 'package:bible/core/domain/model/auth_session.dart';
import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';

/// Issue de [SignInUseCase.execute].
sealed class SignInResult {
  const SignInResult();
}

class SignInSuccess extends SignInResult {
  final AuthSession session;

  const SignInSuccess(this.session);
}

/// Échec : [message] est prêt à afficher, [fieldErrors] renseigne les champs
/// fautifs lorsque le serveur les a détaillés.
class SignInFailure extends SignInResult {
  final String message;
  final Map<String, String> fieldErrors;

  const SignInFailure(this.message, {this.fieldErrors = const {}});
}

/// Connexion e-mail + mot de passe, puis persistance de la session.
class SignInUseCase {
  final AuthRepository _auth;
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const SignInUseCase(this._auth, this._tokenStore, this._logger);

  Future<SignInResult> execute({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _auth.signIn(
        email: email.trim(),
        password: password,
      );
      await _tokenStore.write(session);
      await _logger.info('auth.signed_in');
      return SignInSuccess(session);
    } on AuthException catch (e, stack) {
      // Mot de passe volontairement jamais journalisé.
      await _logger.warn('auth.sign_in_failed', error: e, stack: stack);
      return SignInFailure(e.message, fieldErrors: e.fieldErrors);
    } catch (e, stack) {
      // Filet générique : sans lui, une exception inattendue traverserait le
      // notifier et figerait l'écran de connexion sur son indicateur.
      await _logger.error('auth.sign_in_failed', error: e, stack: stack);
      return const SignInFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
