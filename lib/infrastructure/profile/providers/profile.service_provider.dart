import 'package:bible/core/application/services/profile_application.service.dart';
import 'package:bible/core/application/usecases/delete_account.usecase.dart';
import 'package:bible/core/application/usecases/update_password.usecase.dart';
import 'package:bible/core/application/usecases/update_profile.usecase.dart';
import 'package:bible/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:bible/infrastructure/profile/providers/profile.repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile.service_provider.g.dart';

@riverpod
ProfileApplicationService profileService(Ref ref) {
  final profile = ref.watch(profileRepositoryProvider);
  final tokenStore = ref.watch(authTokenStoreProvider);
  final logger = ref.watch(loggerProvider);
  return ProfileApplicationService(
    updateProfile: UpdateProfileUseCase(profile, tokenStore, logger),
    updatePassword: UpdatePasswordUseCase(profile, logger),
    deleteAccount: DeleteAccountUseCase(profile, tokenStore, logger),
  );
}
