import 'package:flutter/material.dart';
import 'package:mavie/core/theme/app_colors.dart';
import 'package:mavie/core/theme/app_spacing.dart';

/// `null` is unrated, `0` is a real score meaning "terrible" — rendering
/// them the same way is the bug this widget exists to prevent. See
/// [[features/library/_overview]].
class RatingDisplay extends StatelessWidget {
  final double? rating;

  const RatingDisplay({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return Text(
        'Sem nota',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppColors.rating, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(rating!.toStringAsFixed(1)),
      ],
    );
  }
}
