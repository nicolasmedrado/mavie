import 'package:flutter/material.dart';
import 'package:mavie/l10n/generated/app_localizations.dart';

/// Stands in for every route that's wired but not built yet — auth
/// screens, profile, settings, list sub-routes. Keeps the shell fully
/// navigable from day one (FND-10) without pre-stubbing feature folders
/// for issues that haven't landed.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(AppLocalizations.of(context)!.comingSoon)),
    );
  }
}
