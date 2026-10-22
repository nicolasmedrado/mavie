sealed class AppFailure implements Exception {
  const AppFailure();

  /// l10n key for the translated message shown by `AppErrorView` (FND-07).
  String get l10nKey;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  String get l10nKey => 'errorNetwork';
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();

  @override
  String get l10nKey => 'errorUnauthorized';
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure();

  @override
  String get l10nKey => 'errorForbidden';
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure();

  @override
  String get l10nKey => 'errorNotFound';
}

class ValidationFailure extends AppFailure {
  const ValidationFailure();

  @override
  String get l10nKey => 'errorValidation';
}

class UnknownFailure extends AppFailure {
  final Object error;
  final StackTrace stackTrace;

  const UnknownFailure(this.error, this.stackTrace);

  @override
  String get l10nKey => 'errorUnknown';
}
