import 'package:bible/core/application/dtos/user.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/core/domain/exceptions/profile.exception.dart';
import 'package:bible/core/domain/services/auth_token_store.dart';
import 'package:bible/core/domain/services/profile.repository.dart';

/// Issue d'une opération sur le profil.
sealed class ProfileUpdateResult {
  const ProfileUpdateResult();
}

class ProfileUpdated extends ProfileUpdateResult {
  /// Utilisateur à jour, renseigné seulement quand l'opération le renvoie
  /// (mise à jour du nom et de l'e-mail).
  final UserDto? user;

  const ProfileUpdated({this.user});
}

class ProfileUpdateFailure extends ProfileUpdateResult {
  final String message;
  final Map<String, String> fieldErrors;

  const ProfileUpdateFailure(this.message, {this.fieldErrors = const {}});
}

/// Met à jour nom et e-mail, et répercute le changement sur la session
/// stockée : sans cela, l'écran de profil réafficherait l'ancien nom au
/// prochain démarrage, la session locale faisant foi hors ligne.
class UpdateProfileUseCase {
  final ProfileRepository _profile;
  final AuthTokenStore _tokenStore;
  final LoggerApplicationService _logger;

  const UpdateProfileUseCase(this._profile, this._tokenStore, this._logger);

  Future<ProfileUpdateResult> execute({
    required String name,
    required String email,
  }) async {
    try {
      final user = await _profile.updateProfile(
        name: name.trim(),
        email: email.trim(),
      );
      final session = await _tokenStore.read();
      if (session != null) {
        await _tokenStore.write(session.copyWith(user: user));
      }
      await _logger.info('profile.updated');
      return ProfileUpdated(user: UserDto.fromDomain(user));
    } on ProfileException catch (e, stack) {
      await _logger.warn('profile.update_failed', error: e, stack: stack);
      return ProfileUpdateFailure(e.message, fieldErrors: e.fieldErrors);
    } catch (e, stack) {
      await _logger.error('profile.update_failed', error: e, stack: stack);
      return const ProfileUpdateFailure('Une erreur est survenue. Réessayez.');
    }
  }
}
