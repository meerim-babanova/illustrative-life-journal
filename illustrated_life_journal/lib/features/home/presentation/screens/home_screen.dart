import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
import '../../../journal/models/journal_entry.dart';
import '../../../journal/state/journal_provider.dart';
import '../../../stories/data/mock_stories.dart';
import '../../../stories/presentation/widgets/story_card.dart';

/// The main hub screen: character, a low-friction prompt to write, recent
/// memories, and a preview of Stories.
///
/// Per Section 20 (UX principles), this screen avoids feeling like a
/// productivity dashboard — one clear emotional focal point (the
/// character + "what happened today?" prompt), with everything else
/// secondary and lightweight.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onTapNav(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed(AppRoutes.stories);
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.characterStudio);
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final character = context.watch<CharacterProvider>();
    final journal = context.watch<JournalProvider>();
    final textTheme = Theme.of(context).textTheme;
    final recentStories = mockStories.take(2).toList();
    final recentEntries = journal.entries.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > AppBreakpoints.wide;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? AppBreakpoints.wide : double.infinity,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Welcome back', style: textTheme.bodyMedium),
                                  Text(
                                    'Your story continues',
                                    style: textTheme.displayMedium,
                                  ),
                                ],
                              ),
                            ),
                            CharacterPreview(config: character.config, size: 72),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverToBoxAdapter(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('What happened today?', style: textTheme.headlineSmall),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Write a few lines and watch it become a page in your story.',
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: 'Write a memory',
                                icon: Icons.edit_outlined,
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.journalEntry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text('Recent memories', style: textTheme.titleMedium),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: journal.isLoading
                            ? const _RecentMemoriesLoading()
                            : recentEntries.isEmpty
                                ? _RecentMemoriesEmptyState(textTheme: textTheme)
                                : SizedBox(
                                    height: AppSizes.memoryCardHeight,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: recentEntries.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: AppSpacing.sm),
                                      itemBuilder: (context, index) {
                                        final entry = recentEntries[index];
                                        return _RecentMemoryCard(
                                          entry: entry,
                                          onTap: () => Navigator.of(context).pushNamed(
                                            AppRoutes.journalPage,
                                            arguments: entry.id,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Stories', style: textTheme.titleMedium),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(AppRoutes.stories),
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(
                          height: AppSizes.storyCardHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentStories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: AppSizes.storyCardWidth,
                                child: StoryCard(story: recentStories[index]),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onTapNav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined), label: 'Stories'),
          BottomNavigationBarItem(icon: Icon(Icons.face_outlined), label: 'Character'),
        ],
      ),
    );
  }
}

class _RecentMemoriesLoading extends StatelessWidget {
  const _RecentMemoriesLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSizes.memoryCardHeight,
      child: Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
        ),
      ),
    );
  }
}

class _RecentMemoriesEmptyState extends StatelessWidget {
  const _RecentMemoriesEmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.ivoryDim,
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.charcoalFaint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your first memory will show up here once you write one.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact card for a single [JournalEntry] in the Recent Memories strip:
/// thumbnail (if illustrated), title, date, illustration status, and a
/// short preview of the text.
///
/// Every dimension here is fixed via [AppSizes.memoryCardHeight]/
/// [AppSizes.memoryCardWidth] for the same reason [StoryCard] is now
/// fixed-height — deterministic sizing is what guarantees no overflow
/// regardless of font metrics or viewport width.
class _RecentMemoryCard extends StatelessWidget {
  const _RecentMemoryCard({required this.entry, this.onTap});

  final JournalEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SizedBox(
        width: AppSizes.memoryCardWidth,
        height: AppSizes.memoryCardHeight - (AppSpacing.sm * 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 56,
                height: 56,
                child: entry.generationStatus == GenerationStatus.generated &&
                        entry.illustrationUrl != null
                    ? Image.network(
                        entry.illustrationUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _thumbnailFallback(entry.generationStatus),
                      )
                    : _thumbnailFallback(entry.generationStatus),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _statusLabel(entry.generationStatus),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      entry.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailFallback(GenerationStatus status) {
    final icon = switch (status) {
      GenerationStatus.generating => Icons.hourglass_top,
      GenerationStatus.failed => Icons.error_outline,
      _ => Icons.image_outlined,
    };
    return Container(
      color: AppColors.ivoryDim,
      child: Icon(icon, size: 20, color: AppColors.charcoalFaint),
    );
  }

  String _statusLabel(GenerationStatus status) {
    return switch (status) {
      GenerationStatus.generating => 'Illustrating…',
      GenerationStatus.generated => _formatDate(entry.date),
      GenerationStatus.failed => 'Illustration failed',
      GenerationStatus.none => _formatDate(entry.date),
    };
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
