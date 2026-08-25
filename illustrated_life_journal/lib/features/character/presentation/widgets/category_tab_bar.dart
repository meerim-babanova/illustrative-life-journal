import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/customization_asset.dart';

/// Horizontal, scrollable category selector for the Character Studio.
///
/// Renders directly from [categories] rather than hardcoding tabs, so
/// adding a new [CustomizationCategory] (e.g. splitting "Face" into
/// "Face shape" and "Freckles" later) only requires updating the enum and
/// catalog, not this widget.
class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<CustomizationCategory> categories;
  final CustomizationCategory selected;
  final ValueChanged<CustomizationCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(category.label),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.charcoal,
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppColors.surface : AppColors.charcoal,
                  fontSize: 14,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              side: BorderSide(
                color: isSelected ? AppColors.charcoal : AppColors.divider,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          );
        },
      ),
    );
  }
}
