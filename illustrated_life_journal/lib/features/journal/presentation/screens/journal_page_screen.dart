import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../character/state/character_provider.dart';
import '../../../stories/data/mock_stories.dart';
import '../../../stories/models/story.dart';
import '../../models/journal_entry.dart';
import '../../state/journal_provider.dart';

/// The main place a completed memory is displayed: date, title, text, and
/// the generated illustration (or the appropriate in-progress/error/
/// not-yet-generated state for it).
///
/// Design intent: this is the hero screen of the whole app — a journal
/// spread, not a social post. On wide viewports the illustration and the
/// written memory sit side by side like an open storybook page; on
/// narrower viewports they stack, illustration first.
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
        appBar: AppBar(leading: BackButton(onPressed: () => Navigator.of(context).maybePop())),
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
            appBar: AppBar(leading: BackButton(onPressed: () => Navigator.of(context).maybePop())),
            body: Center(
              child: Text('This memory could not be found.', style: textTheme.bodyMedium),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSpread = constraints.maxWidth > AppBreakpoints.medium;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.wide),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: isSpread
                          ? _SpreadLayout(entry: entry)
                          : _StackedLayout(entry: entry),
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
}

/// Wide-viewport layout: illustration and text side by side, like an open
/// book. The illustration takes a fixed proportion of the available width
/// rather than growing without bound, so the spread reads as composed
/// even on very wide desktop windows.
class _SpreadLayout extends StatelessWidget {
  const _SpreadLayout({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _IllustrationArea(entry: entry),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 4,
          child: _JournalContent(entry: entry),
        ),
      ],
    );
  }
}

/// Narrow-viewport layout: illustration first, then text, stacked.
class _StackedLayout extends StatelessWidget {
  const _StackedLayout({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IllustrationArea(entry: entry),
        const SizedBox(height: AppSpacing.lg),
        _JournalContent(entry: entry),
      ],
    );
  }
}

/// Plain manual lookup rather than depending on `package:collection`'s
/// `firstOrNull` extension for this one call site.
Story? _storyFor(String? storyId) {
  if (storyId == null) return null;
  for (final story in mockStories) {
    if (story.id == storyId) return story;
  }
  return null;
}

/// Date, story chip, title, body text, and the regenerate/create action —
/// the "written page" half of the spread, independent of narrow/wide
/// layout.
class _JournalContent extends StatelessWidget {
  const _JournalContent({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final story = _storyFor(entry.storyId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatDate(entry.date), style: textTheme.labelSmall),
        if (story != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _StoryChip(label: story.title),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(entry.title, style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.md),
        Text(entry.text, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        _IllustrationAction(entry: entry),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Back to Home',
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          ),
        ),
      ],
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

/// A small pill labeling which Story this memory belongs to — the
/// "optional story/category" called for in the design brief. Quiet by
/// design: a label, not a button.
class _StoryChip extends StatelessWidget {
  const _StoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.charcoalSoft,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// The create/regenerate button for the illustration, shown beneath the
/// journal text — deliberately a quiet secondary action, never competing
/// with the memory itself for visual weight.
class _IllustrationAction extends StatelessWidget {
  const _IllustrationAction({required this.entry});

  final JournalEntry entry;

  Future<void> _generate(BuildContext context) async {
    final character = context.read<CharacterProvider>().config;
    await context.read<JournalProvider>().generateIllustration(entry.id, character);
  }

  Future<void> _regenerate(BuildContext context) async {
    // A successful illustration already exists — confirm before
    // replacing it, so a regeneration the user didn't really mean to
    // start can't silently swap out one they liked (Section 19 of the
    // spec: a failed regen never loses the old image, but a *successful*
    // regen legitimately replaces it, so this confirmation is the guard
    // against that being accidental).
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Regenerate illustration?'),
        content: const Text(
          "We'll create a new illustration for this memory. Your current "
          'one stays until the new one is ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Regenerate',
            expand: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final character = context.read<CharacterProvider>().config;
    await context.read<JournalProvider>().regenerateIllustration(entry.id, character);
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<JournalProvider>().isGenerating(entry.id);

    if (entry.generationStatus == GenerationStatus.none) {
      return AppButton(
        label: 'Create illustration',
        variant: AppButtonVariant.secondary,
        isLoading: isBusy,
        onPressed: isBusy ? null : () => _generate(context),
      );
    }

    if (entry.generationStatus == GenerationStatus.generated ||
        entry.generationStatus == GenerationStatus.failed) {
      return AppButton(
        label: entry.generationStatus == GenerationStatus.failed
            ? 'Try again'
            : 'Regenerate illustration',
        variant: AppButtonVariant.secondary,
        isLoading: isBusy,
        icon: isBusy ? null : Icons.refresh,
        onPressed: isBusy ? null : () => _regenerate(context),
      );
    }

    // GenerationStatus.generating — the illustration area already shows
    // the in-progress state; no separate action needed here.
    return const SizedBox.shrink();
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
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
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
                    icon: Icons.auto_stories_outlined,
                    message: 'Your illustration got a little lost along the way.',
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
            // non-blocking banner explaining the retry failed. Fixed,
            // reassuring copy — never the raw generationError.
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
                    "Your illustration got a little lost — here's your "
                    'previous one for now.',
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
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: Icon(icon, size: 26, color: AppColors.taupe),
            ),
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
