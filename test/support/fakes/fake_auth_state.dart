import 'package:supabase_flutter/supabase_flutter.dart';

const _fakeUser = User(
  id: 'fake-user-id',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  email: 'fake@mavie.app',
  createdAt: '2026-10-23T00:00:00Z',
);

/// A settled `signedIn` event, for overriding `authStateProvider` in tests
/// that need a real session rather than faking `SupabaseClient` itself.
AuthState signedInAuthState() {
  final session = Session(
    accessToken: 'fake-token',
    tokenType: 'bearer',
    user: _fakeUser,
  );
  return AuthState(AuthChangeEvent.signedIn, session);
}

const signedOutAuthState = AuthState(AuthChangeEvent.signedOut, null);
