import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../data/mappers/app_user_mapper.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

/// Supabase replays the current session to every new listener, so this
/// always has a value immediately — no "waiting for the first event" gap
/// on cold start. AUTH-06 bridges this into `appRouterProvider`'s
/// `refreshListenable` for route gating; until then nothing reads it.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// `null` while the state is still loading and once signed out — both read
/// as "no user" to the rest of the app, which is the distinction that
/// matters pre-AUTH-06: there is no session-restoring UI yet to tell them
/// apart.
final currentUserProvider = Provider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value?.session?.user;
  return user == null ? null : toAppUser(user);
});
