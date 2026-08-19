import 'package:bible/core/domain/services/auth.repository.dart';
import 'package:bible/infrastructure/auth/dio.auth.repository.dart';
import 'package:bible/infrastructure/http/providers/dio.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.repository_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    DioAuthRepository(ref.watch(dioProvider));
