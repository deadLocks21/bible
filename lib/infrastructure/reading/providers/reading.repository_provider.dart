import 'package:bible/core/domain/services/reading.repository.dart';
import 'package:bible/infrastructure/http/providers/dio.provider.dart';
import 'package:bible/infrastructure/reading/dio.reading.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading.repository_provider.g.dart';

@riverpod
ReadingRepository readingRepository(Ref ref) =>
    DioReadingRepository(ref.watch(dioProvider));
