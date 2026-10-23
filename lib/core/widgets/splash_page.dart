import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

/// Shown while `authStateProvider` is restoring the session from secure
/// storage — `appRouterProvider`'s `redirect` (AUTH-06) pins every route
/// here until the first auth event arrives, so the sign-in screen never
/// flashes on a cold start that turns out to already have a session.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppLoadingIndicator());
  }
}
