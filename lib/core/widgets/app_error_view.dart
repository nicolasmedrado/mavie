import 'package:flutter/material.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/theme/app_spacing.dart';

/// Switches on the sealed [AppFailure] from FND-05. Messages are
/// hardcoded Portuguese for now — they become a real lookup on
/// [AppFailure.l10nKey] once FND-08 adds l10n.
class AppErrorView extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
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
            Text(_message(failure), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _message(AppFailure failure) => switch (failure) {
    NetworkFailure() =>
      'Sem conexão. Verifique sua internet e tente novamente.',
    UnauthorizedFailure() => 'Sua sessão expirou. Entre novamente.',
    ForbiddenFailure() => 'Você não tem permissão para ver isso.',
    NotFoundFailure() => 'Não encontramos o que você procurava.',
    ValidationFailure() => 'Algo não é válido. Verifique e tente de novo.',
    UnknownFailure() => 'Algo deu errado. Tente novamente.',
  };
}
