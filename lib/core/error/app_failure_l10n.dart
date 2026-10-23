import 'package:mavie/l10n/generated/app_localizations.dart';

import 'app_failure.dart';

/// The exhaustive switch behind both `AppErrorView` (reads) and any inline
/// `Result.Err` message (writes) — one mapping, so a new `AppFailure`
/// variant is a compile error in exactly one place, not two.
String appFailureMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (failure) {
      NetworkFailure() => l10n.errorNetwork,
      UnauthorizedFailure() => l10n.errorUnauthorized,
      ForbiddenFailure() => l10n.errorForbidden,
      NotFoundFailure() => l10n.errorNotFound,
      ValidationFailure() => l10n.errorValidation,
      UnknownFailure() => l10n.errorUnknown,
    };
