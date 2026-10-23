import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/auth/presentation/pages/settings_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';

import '../../../../support/fakes/fake_auth_repository.dart';
import '../../../../support/pump_app.dart';

void main() {
  testWidgets('tapping sign out calls AuthRepository.signOut', (tester) async {
    final fake = FakeAuthRepository();
    await pumpApp(
      tester,
      const SettingsPage(),
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fake.signOutCallCount, 1);
  });
}
