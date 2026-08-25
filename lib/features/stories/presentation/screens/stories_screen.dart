import 'package:flutter/material.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_stories.dart';
import '../widgets/story_card.dart';

/// Stories: the chapters memories collect into.
///
/// The grid now takes its column count from the responsive tier and a fixed
/// main-axis extent per tile. That is the fix for the overflow stripes: the
/// old delegate combined a max cross-axis extent with childAspectRatio 0.82,
/// so at some widths the tile was shorter than its own content.
class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stories = mockStories;
    final columns = Breakpoints.gridColumns(context, max: 4);

    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth(context)),
            child: stories.isEmpty
                ? _EmptyStoriesState(textTheme: textTheme)
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Text('Chapters your memories are collecting into.',
                          style: textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.lg),
                      GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stories.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisExtent: 220,
                        ),
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return StoryCard(
                            story: story,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"' +
                                      story.title +
                                      '" opens in a later phase.'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
          ),
        ),
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
            const Icon(Icons.auto_stories_outlined,
                size: 40, color: AppColors.charcoalFaint),
            const SizedBox(height: AppSpacing.md),
            Text('No stories yet', style: textTheme.titleMedium),
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
