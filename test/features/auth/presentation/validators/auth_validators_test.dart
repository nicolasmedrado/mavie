import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/auth/presentation/validators/auth_validators.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('validateEmail', () {
    test('rejects an empty value', () {
      expect(validateEmail(l10n, ''), l10n.authErrorEmailRequired);
      expect(validateEmail(l10n, null), l10n.authErrorEmailRequired);
      expect(validateEmail(l10n, '   '), l10n.authErrorEmailRequired);
    });

    test('rejects a malformed email', () {
      expect(validateEmail(l10n, 'not-an-email'), l10n.authErrorEmailInvalid);
      expect(validateEmail(l10n, 'missing@domain'), l10n.authErrorEmailInvalid);
    });

    test('accepts a well-formed email', () {
      expect(validateEmail(l10n, 'nico@mavie.app'), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects an empty value', () {
      expect(validatePassword(l10n, ''), l10n.authErrorPasswordRequired);
      expect(validatePassword(l10n, null), l10n.authErrorPasswordRequired);
    });

    test('rejects a password shorter than minPasswordLength', () {
      expect(
        validatePassword(l10n, 'a' * (minPasswordLength - 1)),
        l10n.authErrorPasswordTooShort(minPasswordLength),
      );
    });

    test('accepts a password exactly minPasswordLength long', () {
      expect(validatePassword(l10n, 'a' * minPasswordLength), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects an empty value', () {
      expect(
        validateConfirmPassword(l10n, '', 'password1'),
        l10n.authErrorConfirmPasswordRequired,
      );
    });

    test('rejects a mismatch', () {
      expect(
        validateConfirmPassword(l10n, 'different', 'password1'),
        l10n.authErrorPasswordMismatch,
      );
    });

    test('accepts a match', () {
      expect(validateConfirmPassword(l10n, 'password1', 'password1'), isNull);
    });
  });
}
