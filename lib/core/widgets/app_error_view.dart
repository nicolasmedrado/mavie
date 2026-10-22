import 'package:flutter/material.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

/// Switches on the sealed [AppFailure] from FND-05, exhaustively mapping
/// each variant to its ARB key — the switch having no `default` is what
/// makes a new, unhandled variant a compile error.
class AppErrorView extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(_message(l10n, failure), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
            ],
          ],
        ),
      ),
    );
  }

  String _message(AppLocalizations l10n, AppFailure failure) =>
      switch (failure) {
        NetworkFailure() => l10n.errorNetwork,
        UnauthorizedFailure() => l10n.errorUnauthorized,
        ForbiddenFailure() => l10n.errorForbidden,
        NotFoundFailure() => l10n.errorNotFound,
        ValidationFailure() => l10n.errorValidation,
        UnknownFailure() => l10n.errorUnknown,
      };
}
