import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/character_provider.dart';
import '../widgets/character_preview.dart';

/// Figma "Screen 1": Create your character.
///
/// This screen's only job is to introduce the idea of the character before
/// handing off to the Character Studio for actual customization.
class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final character = context.watch<CharacterProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Create your character',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "This is how you'll appear in your stories.",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const Spacer(),
              CharacterPreview(config: character.config, size: 220),
              const Spacer(),
              Text(
                "You'll be the main character in every story.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.charcoalFaint),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Continue →',
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.characterStudio),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
