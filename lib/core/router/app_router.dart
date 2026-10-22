import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mavie/core/router/app_routes.dart';
import 'package:mavie/core/router/app_shell.dart';
import 'package:mavie/core/widgets/placeholder_page.dart';
import 'package:mavie/features/movies/presentation/pages/movie_details_page.dart';
import 'package:mavie/features/movies/presentation/pages/movie_search_page.dart';

/// Auth gating (the `redirect` that sends a signed-out user to
/// `/sign-in`, and `refreshListenable` bridging the auth stream) arrives
/// in AUTH-06. Until then every route is reachable directly, and the app
/// still launches straight into the search tab — unchanged from before
/// this issue.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.search,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const PlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const PlaceholderPage(),
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
        builder: (context, state) => const PlaceholderPage(),
      ),
    ],
  );
});
