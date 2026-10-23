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

/// A successful `signUpWithEmail` does not necessarily mean the user is
/// signed in — Supabase's email confirmation setting decides whether a
/// session comes back immediately or only after the user clicks the link
/// in their inbox. If a session *does* come back, the router's `redirect`
/// (AUTH-06) navigates away from here on its own; if it doesn't, this
/// screen's own confirmation message is what the user actually sees.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  AppFailure? _failure;
  String? _confirmationEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        .signUpWithEmail(email: email, password: _passwordController.text);

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
      appBar: AppBar(title: Text(l10n.authSignUpTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _confirmationEmail != null
            ? Center(
                child: Text(
                  l10n.authSignUpConfirmationMessage(_confirmationEmail!),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.authPasswordLabel,
                      ),
                      validator: (value) => validatePassword(l10n, value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.authConfirmPasswordLabel,
                      ),
                      validator: (value) => validateConfirmPassword(
                        l10n,
                        value,
                        _passwordController.text,
                      ),
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
                      label: l10n.authSignUpButton,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.authHaveAccountPrompt),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.authSignInLink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
