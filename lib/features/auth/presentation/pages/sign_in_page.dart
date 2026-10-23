import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/app_failure_l10n.dart';
import 'package:mavie/core/error/result.dart';
import 'package:mavie/core/router/app_routes.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/features/auth/presentation/validators/auth_validators.dart';
import 'package:mavie/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

/// On a successful sign-in, navigation away from here is the router's
/// `redirect` reacting to the auth state change (AUTH-06) — this screen
/// never calls `context.go` itself, per
/// [[architecture/decisions/0010-go-router-declarative-auth]].
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  AppFailure? _failure;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _failure = null;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    switch (result) {
      case Ok():
        setState(() => _isSubmitting = false);
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
      appBar: AppBar(title: Text(l10n.authSignInTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l10n.authEmailLabel),
                validator: (value) => validateEmail(l10n, value),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(labelText: l10n.authPasswordLabel),
                validator: (value) => validatePassword(l10n, value),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: Text(l10n.authForgotPasswordLink),
                ),
              ),
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
                label: l10n.authSignInButton,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.authNoAccountPrompt),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.signUp),
                    child: Text(l10n.authSignUpLink),
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
