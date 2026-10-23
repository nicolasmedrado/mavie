import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/result.dart';
import 'package:mavie/features/auth/presentation/pages/sign_up_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';

import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  testWidgets('shows validation errors for empty fields', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SignUpPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text(l10n.authErrorEmailRequired), findsOneWidget);
    expect(find.text(l10n.authErrorPasswordRequired), findsOneWidget);
    expect(find.text(l10n.authErrorConfirmPasswordRequired), findsOneWidget);
    expect(fake.signUpCallCount, 0);
  });

  testWidgets('rejects a password/confirmation mismatch', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SignUpPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'nico@mavie.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.enterText(find.byType(TextFormField).at(2), 'password2');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text(l10n.authErrorPasswordMismatch), findsOneWidget);
    expect(fake.signUpCallCount, 0);
  });

  testWidgets(
    'submits valid matching credentials and shows the confirmation message',
    (tester) async {
      final fake = FakeAuthRepository();
      await pumpApp(
        tester,
        const SignUpPage(),
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
      );
      final l10n = l10nOf(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'nico@mavie.app',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password1');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(fake.signUpCallCount, 1);
      expect(fake.lastEmail, 'nico@mavie.app');
      expect(fake.lastPassword, 'password1');
      expect(
        find.text(l10n.authSignUpConfirmationMessage('nico@mavie.app')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows the mapped failure message when sign-up fails', (
    tester,
  ) async {
    final fake = FakeAuthRepository(
      signUpResult: const Err(ValidationFailure()),
    );
    await pumpApp(
      tester,
      const SignUpPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'nico@mavie.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorValidation), findsOneWidget);
  });
}
