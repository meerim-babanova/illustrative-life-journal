import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../character/state/character_provider.dart';
import '../../models/journal_entry.dart';
import '../../state/journal_provider.dart';

/// The main place a completed memory is displayed: date, title, text, and
/// the generated illustration (or the appropriate in-progress/error/
/// not-yet-generated state for it).
///
/// Reads the entry live from [JournalProvider] by id (from route
/// arguments) rather than holding its own copy, so it always reflects the
/// latest persisted state — including after a regenerate or a page
/// refresh.
class JournalPageScreen extends StatelessWidget {
  const JournalPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entryId = ModalRoute.of(context)?.settings.arguments;
    final textTheme = Theme.of(context).textTheme;

    if (entryId is! String) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal Page')),
        body: Center(
          child: Text('No memory to show.', style: textTheme.bodyMedium),
        ),
      );
    }

    return Consumer<JournalProvider>(
      builder: (context, journal, _) {
        final entry = journal.entryById(entryId);

        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Journal Page')),
            body: Center(
              child: Text('This memory could not be found.', style: textTheme.bodyMedium),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Your page')),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 640;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _IllustrationArea(entry: entry),
                          const SizedBox(height: AppSpacing.lg),
                          Text(entry.title, style: textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(_formatDate(entry.date), style: textTheme.labelSmall),
                          const SizedBox(height: AppSpacing.md),
                          Text(entry.text, style: textTheme.bodyLarge),
                          const SizedBox(height: AppSpacing.lg),
                          if (entry.generationStatus == GenerationStatus.generated ||
                              entry.generationStatus == GenerationStatus.failed)
                            AppButton(
                              label: entry.generationStatus == GenerationStatus.failed
                                  ? 'Try again'
                                  : 'Regenerate illustration',
                              variant: AppButtonVariant.secondary,
                              onPressed: () {
                                final character = context.read<CharacterProvider>().config;
                                context
                                    .read<JournalProvider>()
                                    .regenerateIllustration(entry.id, character);
                              },
                            ),
                          if (entry.generationStatus == GenerationStatus.none)
                            AppButton(
                              label: 'Create illustration',
                              variant: AppButtonVariant.secondary,
                              onPressed: () {
                                final character = context.read<CharacterProvider>().config;
                                context
                                    .read<JournalProvider>()
                                    .generateIllustration(entry.id, character);
                              },
                            ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Back to Home',
                            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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

/// Renders the correct illustration state per Section 18 of the spec:
/// generated -> the image; generating -> in-progress; failed -> retry;
/// none -> "will be generated" placeholder, only ever shown for an entry
/// that genuinely has no illustration attempt yet.
///
/// Critically, [entry.illustrationUrl] is checked *before* status — a
/// failed regeneration sets status to [GenerationStatus.failed] while
/// deliberately leaving a prior successful [illustrationUrl] in place
/// (see [JournalProvider.generateIllustration]). If this widget switched
/// on status alone, that preserved URL would never actually be shown,
/// silently defeating Section 19's "keep the existing successful image"
/// requirement at the UI layer even though the data layer honors it.
class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasImage = entry.illustrationUrl != null;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ivoryDim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                entry.illustrationUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.coral),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _StatusMessage(
                  icon: Icons.image_not_supported_outlined,
                  message: "This illustration couldn't be loaded.",
                  textTheme: textTheme,
                ),
              )
            else
              switch (entry.generationStatus) {
                GenerationStatus.generating => const Center(
                    child: CircularProgressIndicator(color: AppColors.coral),
                  ),
                GenerationStatus.failed => _StatusMessage(
                    icon: Icons.error_outline,
                    message: entry.generationError ??
                        "We couldn't create the illustration this time.",
                    textTheme: textTheme,
                  ),
                _ => _StatusMessage(
                    icon: Icons.image_outlined,
                    message: "Your illustration hasn't been created yet.",
                    textTheme: textTheme,
                  ),
              },
            // A regeneration in flight for an entry that already has a
            // successful image: dim it and show a spinner on top, rather
            // than hiding it the way the "no prior image" branch above does.
            if (hasImage && entry.generationStatus == GenerationStatus.generating)
              Container(
                color: AppColors.charcoal.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.surface),
                ),
              ),
            // A regeneration that failed for an entry that already has a
            // successful image: keep showing that image, with a small
            // non-blocking banner explaining the retry failed.
            if (hasImage && entry.generationStatus == GenerationStatus.failed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  color: AppColors.charcoal.withValues(alpha: 0.78),
                  child: Text(
                    entry.generationError ??
                        'Regeneration failed — showing your previous illustration.',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(color: AppColors.surface),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.message,
    required this.textTheme,
  });

  final IconData icon;
  final String message;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.charcoalFaint),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
