import 'package:mavie/l10n/generated/app_localizations.dart';

/// Matches `supabase/config.toml`'s `[auth.email] minimum_password_length`
/// — rejecting a short password client-side instead of round-tripping to
/// find out the server also rejects it.
const minPasswordLength = 6;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(AppLocalizations l10n, String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return l10n.authErrorEmailRequired;
  if (!_emailPattern.hasMatch(email)) return l10n.authErrorEmailInvalid;
  return null;
}

String? validatePassword(AppLocalizations l10n, String? value) {
  final password = value ?? '';
  if (password.isEmpty) return l10n.authErrorPasswordRequired;
  if (password.length < minPasswordLength) {
    return l10n.authErrorPasswordTooShort(minPasswordLength);
  }
  return null;
}

String? validateConfirmPassword(
  AppLocalizations l10n,
  String? value,
  String password,
) {
  final confirmation = value ?? '';
  if (confirmation.isEmpty) return l10n.authErrorConfirmPasswordRequired;
  if (confirmation != password) return l10n.authErrorPasswordMismatch;
  return null;
}
