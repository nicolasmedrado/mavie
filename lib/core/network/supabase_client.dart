import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `bootstrap()` calls `Supabase.initialize` before `runApp`, so
/// `Supabase.instance.client` is always ready by the time any provider
/// first reads this.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
