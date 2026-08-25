import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/journal_provider.dart';
import '../widgets/regenerate_sheet.dart';
import '../widgets/scene_illustration.dart';

/// The finished journal page: a spread, not a post.
///
/// The illustration is the hero, the writing keeps full weight underneath it
/// in serif at reading size, and the page's own metadata (date, story,
/// character credit, regenerate) sits in a quiet rail.
class JournalPageScreen extends StatelessWidget {
  const JournalPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final page = journal.currentPage;
    final textTheme = Theme.of(context).textTheme;
    final wide = Breakpoints.isWide(context);

    if (page == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your page')),
        body: Center(
          child: Text('No page to show yet.', style: textTheme.bodyMedium),
        ),
      );
    }

    Future<void> regenerate() async {
      final result = await showRegenerateSheet(
        context,
        takes: page.previousTakes,
      );
      if (result == null) return;
      if (result.restore != null) {
        journal.restoreTake(result.restore!);
        return;
      }
      await journal.regenerate(nudge: result.nudge);
    }

    final illustration = Stack(
      children: [
        AspectRatio(
          aspectRatio: wide ? 16 / 9 : 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SceneIllustration(scene: page.scene),
          ),
        ),
        Positioned(
          left: AppSpacing.md,
          bottom: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.ivory.withOpacity(0.94),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Your character appears in this page',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (journal.isWorking)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.ivory.withOpacity(0.72),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Center(
                child: Text('Drawing it again…', style: textTheme.titleMedium),
              ),
            ),
          ),
      ],
    );

    final words = Text(
      page.text,
      style: textTheme.headlineSmall?.copyWith(
        fontSize: wide ? 21 : 19,
        height: 1.8,
        fontWeight: FontWeight.w400,
      ),
    );

    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('THIS PAGE',
            style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          page.scene.details.join(' · '),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Drawn from your words. If it doesn't feel like your memory, try another take — your writing stays exactly as it is.",
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Regenerate illustration',
          icon: Icons.refresh,
          variant: AppButtonVariant.secondary,
          isLoading: journal.isWorking,
          onPressed: regenerate,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Keep this page',
          onPressed: () {
            journal.keepPage();
            journal.reset();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your page')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth(context)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(page.date).toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(page.title, style: textTheme.displayLarge),
                      ),
                      if (page.storyTitle != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.ivoryDim,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text('Story · ' + page.storyTitle!,
                              style: textTheme.labelSmall),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  illustration,
                  const SizedBox(height: AppSpacing.lg),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: words),
                        const SizedBox(width: AppSpacing.xl),
                        SizedBox(width: 264, child: rail),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        words,
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                        rail,
                      ],
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    return date.day.toString() +
        ' ' +
        months[date.month - 1] +
        ' ' +
        date.year.toString();
  }
}
