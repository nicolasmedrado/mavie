import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/app_failure_l10n.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('every AppFailure variant maps to its matching l10n message', () {
    expect(appFailureMessage(l10n, const NetworkFailure()), l10n.errorNetwork);
    expect(
      appFailureMessage(l10n, const UnauthorizedFailure()),
      l10n.errorUnauthorized,
    );
    expect(
      appFailureMessage(l10n, const ForbiddenFailure()),
      l10n.errorForbidden,
    );
    expect(
      appFailureMessage(l10n, const NotFoundFailure()),
      l10n.errorNotFound,
    );
    expect(
      appFailureMessage(l10n, const ValidationFailure()),
      l10n.errorValidation,
    );
    expect(
      appFailureMessage(
        l10n,
        UnknownFailure(StateError('x'), StackTrace.current),
      ),
      l10n.errorUnknown,
    );
  });
}
