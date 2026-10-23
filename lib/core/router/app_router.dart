import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/router/app_routes.dart';
import 'package:mavie/core/router/app_shell.dart';
import 'package:mavie/core/widgets/placeholder_page.dart';
import 'package:mavie/core/widgets/splash_page.dart';
import 'package:mavie/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mavie/features/auth/presentation/pages/settings_page.dart';
import 'package:mavie/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mavie/features/auth/presentation/pages/sign_up_page.dart';
import 'package:mavie/features/auth/presentation/providers/auth_providers.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';

const _authRoutes = {
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
};

/// Never `ref.watch` the auth state in here — that would rebuild the whole
/// `GoRouter` on every auth event and wipe the navigation stack. `redirect`
/// reads it lazily instead, and `refreshListenable` is what actually tells
/// `GoRouter` to re-run `redirect` on a change —
/// [[architecture/decisions/0010-go-router-declarative-auth]].
///
/// The refresh signal comes from `ref.listen(authStateProvider, ...)`
/// rather than a second direct subscription to `SupabaseClient.auth.
/// onAuthStateChange` — one fewer listener on the same stream, and it
/// keeps this provider's only dependency on auth state as `authStateProvider`
/// itself, which tests already know how to override.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();
  final subscription = ref.listen(
    authStateProvider,
    (previous, next) => refreshNotifier.notify(),
  );
  ref.onDispose(subscription.close);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.search,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const PlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const MovieSearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const PlaceholderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.lists,
                builder: (context, state) => const PlaceholderPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.movieDetailsPattern,
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return MovieDetailsPage(movieId: movieId);
        },
      ),
      GoRoute(
        path: AppRoutes.newList,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.listDetailPattern,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.listMembersPattern,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  if (authState.isLoading) {
    return state.matchedLocation == AppRoutes.splash
        ? null
        : AppRoutes.splash;
  }

  // Derived directly from authState, not currentUserProvider: this runs
  // synchronously inside the same `ref.listen(authStateProvider, ...)`
  // callback stack that fired on the very same auth change. A `Provider`
  // that `ref.watch`es authStateProvider (currentUserProvider) hasn't
  // necessarily recomputed yet at this exact point — Riverpod notifies the
  // direct listener before it flushes dependents — so reading it here would
  // see last auth event's value, one event behind. Found by instrumenting
  // this function: the signed-in event logged correctly in authState while
  // currentUserProvider's own listener fired only afterwards. See
  // [[architecture/overview]] / [[_meta/discrepancies]].
  final isSignedIn = authState.value?.session?.user != null;
  final isAuthRoute = _authRoutes.contains(state.matchedLocation);
  final isSplash = state.matchedLocation == AppRoutes.splash;

  if (!isSignedIn) {
    return isAuthRoute ? null : AppRoutes.signIn;
  }
  if (isAuthRoute || isSplash) {
    // AppRoutes.home is still a placeholder (HOME-01) — landing signed-in
    // users on search instead matches initialLocation and today's real
    // screen. Revisit once Home is the actual landing experience.
    return AppRoutes.search;
  }
  return null;
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
