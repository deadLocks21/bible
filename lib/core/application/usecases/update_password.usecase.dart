import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/services/profile.repository.dart';

/// Change le mot de passe du compte.
///
/// Le jeton de cet appareil survit à l'opération (côté serveur, seuls les
/// autres sont révoqués) : l'utilisateur n'est pas déconnecté de l'écran depuis
/// lequel il vient de changer son mot de passe.
class UpdatePasswordUseCase {
  final ProfileRepository _profile;
  final LoggerApplicationService _logger;

  const UpdatePasswordUseCase(this._profile, this._logger);

  Future<ProfileUpdateResult> execute({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      return const ProfileUpdateFailure(
        'Les mots de passe ne correspondent pas.',
        fieldErrors: {
          'password_confirmation': 'Les mots de passe ne correspondent pas.',
        },
      );
    }
    try {
      await _profile.updatePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _logger.info('profile.password_updated');
      return const ProfileUpdated();
    } on ProfileException catch (e, stack) {
      // Mots de passe volontairement jamais journalisés.
      await _logger.warn('profile.password_update_failed', error: e, stack: stack);
      return ProfileUpdateFailure(e.message, fieldErrors: e.fieldErrors);
    } catch (e, stack) {
      await _logger.error('profile.password_update_failed', error: e, stack: stack);
      return const ProfileUpdateFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
