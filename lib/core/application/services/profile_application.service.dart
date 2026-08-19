import 'package:bible/core/application/usecases/delete_account.usecase.dart';
import 'package:bible/core/application/usecases/update_password.usecase.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';

/// Regroupe les cas d'usage de gestion du compte.
class ProfileApplicationService {
  final UpdateProfileUseCase updateProfile;
  final UpdatePasswordUseCase updatePassword;
  final DeleteAccountUseCase deleteAccount;

  const ProfileApplicationService({
    required this.updateProfile,
    required this.updatePassword,
    required this.deleteAccount,
  });
}
