import 'package:flutter/material.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/app_failure_l10n.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

/// Renders the sealed [AppFailure] from FND-05 via [appFailureMessage] —
/// the exhaustive switch lives there so AUTH-04's inline `Result.Err`
/// messages share it instead of duplicating the mapping.
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
            Text(appFailureMessage(l10n, failure), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
            ],
          ],
        ),
      ),
    );
  }
}
