import 'package:flutter/material.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/character_preview.dart';
import '../../models/character_config.dart';

/// The very first screen a new user sees.
///
/// Kept deliberately simple and emotional per Section 20 (UX principles):
/// one focal point, no clutter, and an immediate sense of "this is a
/// personal illustrated world," not a utility app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              CharacterPreview(config: CharacterConfig.defaultConfig(), size: 180),
              const Spacer(flex: 1),
              Text(
                'Illustrated Life Journal',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'See your life as a beautiful illustrated story.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.charcoalSoft),
              ),
              const Spacer(flex: 2),
              AppButton(
                label: 'Get started',
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.characterIntro),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
