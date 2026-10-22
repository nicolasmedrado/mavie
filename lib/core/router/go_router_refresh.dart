import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] into a [Listenable] `GoRouter.refreshListenable` can
/// subscribe to, so e.g. an auth state change re-evaluates `redirect`
/// without rebuilding the whole `GoRouter` — which `ref.watch`ing auth
/// state directly inside the router provider would do, wiping the
/// navigation stack on every event.
///
/// Written now, wired in AUTH-06 once an auth state stream exists.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
