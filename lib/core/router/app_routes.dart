/// Path constants and typed helpers for navigation — no string literals at
/// call sites. `*Pattern` constants are the `path:` templates `GoRoute`
/// declarations use; the plain constants are concrete, navigable paths.
abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const search = '/search';
  static const library = '/library';
  static const lists = '/lists';

  static const newList = '/lists/new';
  static const profile = '/profile';
  static const settings = '/settings';

  static const movieDetailsPattern = '/movie/:id';
  static String movieDetails(int movieId) => '/movie/$movieId';

  static const listDetailPattern = '/lists/:listId';
  static String listDetail(String listId) => '/lists/$listId';

  static const listMembersPattern = '/lists/:listId/members';
  static String listMembers(String listId) => '/lists/$listId/members';
}
