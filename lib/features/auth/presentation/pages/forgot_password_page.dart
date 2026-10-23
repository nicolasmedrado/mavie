import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/app_failure_l10n.dart';
import 'package:mavie/core/error/result.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/features/auth/presentation/validators/auth_validators.dart';
import 'package:mavie/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  AppFailure? _failure;
  String? _confirmationEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _failure = null;
    });

    final email = _emailController.text.trim();
    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordResetEmail(email);

    if (!mounted) return;

    switch (result) {
      case Ok():
        setState(() {
          _isSubmitting = false;
          _confirmationEmail = email;
        });
      case Err(:final failure):
        setState(() {
          _isSubmitting = false;
          _failure = failure;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authForgotPasswordTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _confirmationEmail != null
            ? Center(
                child: Text(
                  l10n.authPasswordResetConfirmationMessage(
                    _confirmationEmail!,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                      ),
                      validator: (value) => validateEmail(l10n, value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_failure != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          appFailureMessage(l10n, _failure!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    AuthSubmitButton(
                      label: l10n.authSendResetLinkButton,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n.authBackToSignIn),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
