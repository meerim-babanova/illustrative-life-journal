import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/journal_provider.dart';

/// Displays the resulting Journal Page after (mock) generation.
///
/// The illustration itself is a placeholder — a soft colored panel with an
/// icon — standing in for the real illustrated scene that Phases 4-6 will
/// produce via the AI Director + image generation pipeline.
class JournalPageScreen extends StatelessWidget {
  const JournalPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final page = journal.currentPage;
    final textTheme = Theme.of(context).textTheme;

    if (page == null) {
      // Defensive fallback — shouldn't normally be reachable since this
      // screen is only pushed once currentPage is populated.
      return Scaffold(
        appBar: AppBar(title: const Text('Journal Page')),
        body: Center(
          child: Text('No page to show yet.', style: textTheme.bodyMedium),
        ),
      );
    }

    final palette = AppColors.placeholderPalette;
    final color = palette[page.illustrationSeed % palette.length];

    return Scaffold(
      appBar: AppBar(title: const Text('Your page')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined, size: 48, color: color),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Illustration coming in a later phase',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(page.title, style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(page.date),
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(page.text, style: textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Back to Home',
                onPressed: () {
                  journal.reset();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
