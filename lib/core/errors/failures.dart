import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.cache({
    @Default('خطأ في التخزين المحلي') String message,
  }) = CacheFailure;

  const factory Failure.unknown({
    @Default('حدث خطأ غير متوقع') String message,
  }) = UnknownFailure;
}

extension FailureX on Failure {
  String get userMessage => when(
    cache:   (m) => m,
    unknown: (m) => m,
  );
}
