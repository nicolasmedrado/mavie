import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/core/error/app_failure.dart';
import 'package:mavie/core/error/result.dart';
import 'package:mavie/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';

import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  testWidgets('shows validation errors for empty email and password', (
    tester,
  ) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SignInPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text(l10n.authErrorEmailRequired), findsOneWidget);
    expect(find.text(l10n.authErrorPasswordRequired), findsOneWidget);
    expect(fake.signInCallCount, 0);
  });

  testWidgets('rejects a malformed email', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SignInPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text(l10n.authErrorEmailInvalid), findsOneWidget);
    expect(fake.signInCallCount, 0);
  });

  testWidgets('submits valid credentials to the repository', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SignInPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'nico@mavie.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fake.signInCallCount, 1);
    expect(fake.lastEmail, 'nico@mavie.app');
    expect(fake.lastPassword, 'password1');
  });

  testWidgets('shows the mapped failure message when sign-in fails', (
    tester,
  ) async {
    final fake = FakeAuthRepository(
      signInResult: const Err(UnauthorizedFailure()),
    );
    await pumpApp(
      tester,
      const SignInPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    final l10n = l10nOf(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'nico@mavie.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorUnauthorized), findsOneWidget);
  });
}
