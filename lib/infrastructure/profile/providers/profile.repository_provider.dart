import 'package:bible/core/domain/services/profile.repository.dart';
import 'package:bible/infrastructure/http/providers/dio.provider.dart';
import 'package:bible/infrastructure/profile/dio.profile.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile.repository_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    DioProfileRepository(ref.watch(dioProvider));
