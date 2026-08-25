import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

/// The friendly "generation failed" state, shared by the full-screen
/// Generation flow and (in spirit) the inline banner on the Journal Page.
///
/// Deliberately muted/taupe rather than alarm-red — a failed illustration
/// is a small disappointment in a cozy diary, not a system error. Never
/// shown alongside the raw [entry.generationError] message from the
/// backend/provider; only ever the fixed, reassuring copy below.
class FriendlyFailureState extends StatelessWidget {
  const FriendlyFailureState({
    super.key,
    required this.onRetry,
    this.onBack,
  });

  final VoidCallback onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ivoryDim,
          ),
          child: const Icon(
            Icons.auto_stories_outlined,
            color: AppColors.taupe,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Your illustration got a little lost along the way.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Let's try again.",
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(label: 'Try again', expand: false, onPressed: onRetry),
            if (onBack != null) ...[
              const SizedBox(width: AppSpacing.md),
              AppButton(
                label: 'Back to story',
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: onBack,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
