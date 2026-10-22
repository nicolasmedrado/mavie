import 'package:flutter/material.dart';

/// Colours with nowhere else to live — not part of [ColorScheme], but
/// shared across screens. Everything else should come from
/// `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  static const seed = Colors.deepPurple;

  /// The rating star/score colour. Shared by the details screen, list
  /// rows, member chips and carousels — a named token, not `Colors.amber`
  /// repeated at every call site.
  static const rating = Colors.amber;

  /// Background for a poster with no image, before `MoviePoster` (FND-07)
  /// replaces the duplicated placeholder logic.
  static const posterPlaceholder = Colors.black12;
}
