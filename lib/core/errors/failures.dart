/// Domain-level failures — no Freezed, plain sealed class.
sealed class Failure {
  const Failure(this.message);
  final String message;
  String get userMessage => message;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطأ في التخزين المحلي']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}
