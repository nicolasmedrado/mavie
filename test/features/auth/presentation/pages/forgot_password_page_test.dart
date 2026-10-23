import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/result.dart';
import 'package:mavie/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';

import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  testWidgets('shows a validation error for an empty email', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const ForgotPasswordPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text(l10n.authErrorEmailRequired), findsOneWidget);
    expect(fake.sendPasswordResetEmailCallCount, 0);
  });

  testWidgets('submits a valid email and shows the confirmation message', (
    tester,
  ) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const ForgotPasswordPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField), 'nico@mavie.app');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fake.sendPasswordResetEmailCallCount, 1);
    expect(fake.lastEmail, 'nico@mavie.app');
    expect(
      find.text(l10n.authPasswordResetConfirmationMessage('nico@mavie.app')),
      findsOneWidget,
    );
  });

  testWidgets('shows the mapped failure message when the request fails', (
    tester,
  ) async {
    final fake = FakeAuthRepository(
      sendPasswordResetEmailResult: const Err(NetworkFailure()),
    );
    await pumpApp(
      tester,
      const ForgotPasswordPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField), 'nico@mavie.app');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorNetwork), findsOneWidget);
  });
}
