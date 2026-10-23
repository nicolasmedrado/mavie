import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mavie/core/theme/app_spacing.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

/// Stand-in for AUTH-07's real Profile/Settings screen (display name,
/// avatar, language, sign out) — this issue only needs sign-out to be
/// reachable and working. Navigating away afterwards is the router's
/// `redirect` reacting to the auth state change, same as sign-in.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FilledButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: Text(l10n.authSignOutButton),
        ),
      ),
    );
  }
}
