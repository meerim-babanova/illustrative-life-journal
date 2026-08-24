import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/journal_provider.dart';

/// Loading/processing screen between writing an entry and seeing the
/// resulting Journal Page.
///
/// Watches [JournalProvider] and automatically advances to the Journal Page
/// once generation finishes, or shows a retry option on error.
class GenerationScreen extends StatelessWidget {
  const GenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final textTheme = Theme.of(context).textTheme;

    if (!journal.isGenerating && journal.currentPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.journalPage);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: journal.error != null
                ? _ErrorState(message: journal.error!, textTheme: textTheme)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.coral,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Turning today into a page in your story…',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'This will just take a moment.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.textTheme});

  final String message;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: AppColors.coralDeep, size: 36),
        const SizedBox(height: AppSpacing.md),
        Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Go back',
          expand: false,
          onPressed: () => Navigator.of(context).popUntil(
            (route) => route.settings.name == AppRoutes.home,
          ),
        ),
      ],
    );
  }
}
