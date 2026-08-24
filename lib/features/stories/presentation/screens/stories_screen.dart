import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_stories.dart';
import '../widgets/story_card.dart';

/// Basic Stories screen for Phase 1 (Section 22): shows mock stories in a
/// grid, or an empty state if there are none. Tapping a story is a no-op
/// placeholder until Phase 3 introduces Story Detail with real entries.
class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stories = mockStories;

    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: stories.isEmpty
          ? _EmptyStoriesState(textTheme: textTheme)
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: stories.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final story = stories[index];
                return StoryCard(
                  story: story,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Story Detail for "${story.title}" arrives in a later phase.',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyStoriesState extends StatelessWidget {
  const _EmptyStoriesState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 40,
              color: AppColors.charcoalFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No stories yet',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Group your memories into stories like trips or seasons.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
