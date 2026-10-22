import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';

// Exhaustive, no default clause — if a new AppFailure variant is added
// without a case here, this stops compiling. That is the property FND-05
// protects.
String _describe(AppFailure failure) => switch (failure) {
  NetworkFailure() => 'network',
  UnauthorizedFailure() => 'unauthorized',
  ForbiddenFailure() => 'forbidden',
  NotFoundFailure() => 'not found',
  ValidationFailure() => 'validation',
  UnknownFailure() => 'unknown',
};

void main() {
  test('every AppFailure variant carries a distinct l10n key', () {
    const failures = <AppFailure>[
      NetworkFailure(),
      UnauthorizedFailure(),
      ForbiddenFailure(),
      NotFoundFailure(),
      ValidationFailure(),
    ];
    final unknown = UnknownFailure(StateError('x'), StackTrace.current);

    final keys = {
      for (final failure in failures) failure.l10nKey,
      unknown.l10nKey,
    };

    expect(keys, hasLength(failures.length + 1));
  });

  test('an exhaustive switch compiles without a default clause', () {
    expect(_describe(const NetworkFailure()), 'network');
    expect(_describe(const UnauthorizedFailure()), 'unauthorized');
    expect(_describe(const ForbiddenFailure()), 'forbidden');
    expect(_describe(const NotFoundFailure()), 'not found');
    expect(_describe(const ValidationFailure()), 'validation');
    expect(
      _describe(UnknownFailure(StateError('x'), StackTrace.current)),
      'unknown',
    );
  });

  test('UnknownFailure keeps the original error and stack trace', () {
    final stackTrace = StackTrace.current;
    final original = StateError('boom');

    final failure = UnknownFailure(original, stackTrace);

    expect(failure.error, same(original));
    expect(failure.stackTrace, same(stackTrace));
  });
}
