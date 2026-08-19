import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/core/domain/services/profile.repository.dart';

/// Supprime le compte, puis la session locale.
///
/// L'effacement local n'a lieu qu'en cas de succès : si la suppression échoue
/// (mot de passe erroné, serveur injoignable), l'utilisateur reste connecté à
/// un compte qui existe toujours.
class DeleteAccountUseCase {
  final ProfileRepository _profile;
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const DeleteAccountUseCase(this._profile, this._tokenStore, this._logger);

  Future<ProfileUpdateResult> execute({required String password}) async {
    try {
      await _profile.deleteAccount(password: password);
      await _tokenStore.clear();
      await _logger.info('profile.deleted');
      return const ProfileUpdated();
    } on ProfileException catch (e, stack) {
      await _logger.warn('profile.delete_failed', error: e, stack: stack);
      return ProfileUpdateFailure(e.message, fieldErrors: e.fieldErrors);
    } catch (e, stack) {
      await _logger.error('profile.delete_failed', error: e, stack: stack);
      return const ProfileUpdateFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
