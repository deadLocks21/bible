// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingService)
final readingServiceProvider = ReadingServiceProvider._();

final class ReadingServiceProvider
    extends
        $FunctionalProvider<
          ReadingApplicationService,
          ReadingApplicationService,
          ReadingApplicationService
        >
    with $Provider<ReadingApplicationService> {
  ReadingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingServiceHash();

  @$internal
  @override
  $ProviderElement<ReadingApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingApplicationService create(Ref ref) {
    return readingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingApplicationService>(value),
    );
  }
}

String _$readingServiceHash() => r'2f78a72d75a45407cfef39352bb313d2c6dbc7d8';
