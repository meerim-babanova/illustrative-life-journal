import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
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

    return Scaffold(
      body: SafeArea(
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
                          Text('Your story continues', style: textTheme.displayMedium),
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
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.journalEntry),
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
                child: journal.recentPages.isEmpty
                    ? _RecentMemoriesEmptyState(textTheme: textTheme)
                    : SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: journal.recentPages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final page = journal.recentPages[index];
                            return AppCard(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: SizedBox(
                                width: 160,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      page.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium,
                                    ),
                                    Text(
                                      page.text,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
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
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentStories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 150,
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
