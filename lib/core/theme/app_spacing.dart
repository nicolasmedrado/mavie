/// A 4pt spacing scale, plus the radius and elevation tokens that come
/// with it. Replaces literal `SizedBox`/`BorderRadius.circular` values.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double radiusSm = 4;
  static const double radiusMd = 8;

  static const double elevationSm = 1;
  static const double elevationMd = 3;

  /// Search-result thumbnail poster size. Becomes a `MoviePoster` size
  /// variant in FND-07.
  static const double posterThumbnailWidth = 48;
  static const double posterThumbnailHeight = 72;
}
