import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/customization_asset.dart';

/// Renders the selectable options for the active customization category.
///
/// Entirely data-driven: it knows nothing about "hair" or "face"
/// specifically, only about a list of [CustomizationAsset]. This is what
/// lets the studio scale to hundreds of assets later without UI rewrites
/// (see spec Section 9, "Character Asset Architecture").
class OptionGrid extends StatelessWidget {
  const OptionGrid({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CustomizationAsset> options;
  final String? selectedId;
  final ValueChanged<CustomizationAsset> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            'More options coming soon.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.id == selectedId;
        return _OptionTile(
          option: option,
          isSelected: isSelected,
          onTap: () => onSelected(option),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CustomizationAsset option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: option.swatch ?? AppColors.ivoryDim,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.coral : AppColors.divider,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: option.swatch == null
                ? Icon(
                    Icons.check_circle_outline,
                    color: isSelected
                        ? AppColors.coralDeep
                        : AppColors.charcoalFaint,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            option.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isSelected ? AppColors.coralDeep : AppColors.charcoalSoft,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
