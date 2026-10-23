import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/auth/domain/entities/app_user.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _user = User(
  id: 'u1',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  email: 'a@mavie.app',
  createdAt: '2026-10-22T00:00:00Z',
);

/// `StreamProvider.future` does not resolve reliably for an already-settled
/// `Stream.value` in this riverpod version (reproduced against a bare
/// `StreamProvider<int>`, independent of anything auth-specific) — it hangs
/// until the test's own timeout tears the container down mid-`loading`.
/// Subscribing with `listen` and pumping the microtask queue drives the
/// same stream event through without relying on that accessor.
Future<void> _settle(ProviderContainer container) async {
  container.listen(authStateProvider, (previous, next) {});
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test(
    'currentUserProvider derives the signed-in user from authState',
    () async {
      final session = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: _user,
      );
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(AuthState(AuthChangeEvent.signedIn, session)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _settle(container);

      expect(
        container.read(currentUserProvider),
        const AppUser(id: 'u1', email: 'a@mavie.app'),
      );
    },
  );

  test('currentUserProvider is null once signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) =>
              Stream.value(const AuthState(AuthChangeEvent.signedOut, null)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _settle(container);

    expect(container.read(currentUserProvider), isNull);
  });

  test('currentUserProvider is null while authState is still loading', () {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(currentUserProvider), isNull);
  });
}
