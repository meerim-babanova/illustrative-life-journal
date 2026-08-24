import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/story.dart';

/// A single Story tile: a cover (an illustration thumbnail if one exists,
/// otherwise a placeholder color/icon), title, and entry count.
///
/// The cover uses a fixed [AppSizes.storyCoverHeight] rather than an
/// `AspectRatio` — a width-proportional cover combined with variable-width
/// text previously produced overflow at some card widths (see
/// [AppSizes.storyCardHeight] for the full explanation). Every dimension
/// here is fixed, so the card's total height is identical — and always
/// fits — at any width the grid or horizontal strip gives it.
class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story, this.onTap});

  final Story story;
  final VoidCallback? onTap;

  Color _coverColor() {
    const palette = AppColors.placeholderPalette;
    final index = (story.coverColorSeed ?? 0) % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final coverColor = _coverColor();
    final thumbnailUrl = story.thumbnailUrl;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: onTap != null,
        label: '${story.title}, ${story.entryCount} '
            '${story.entryCount == 1 ? 'memory' : 'memories'}',
        child: SizedBox(
          height: AppSizes.storyCardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppSizes.storyCoverHeight,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderCover(coverColor),
                        )
                      : _placeholderCover(coverColor),
                ),
              ),
              SizedBox(
                height: AppSizes.storyTextBlockHeight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        story.title,
                        style: textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${story.entryCount} ${story.entryCount == 1 ? 'memory' : 'memories'}',
                        style: textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderCover(Color color) {
    return Container(
      color: color.withValues(alpha: 0.35),
      child: Center(
        child: Icon(Icons.auto_stories_outlined, color: color, size: 32),
      ),
    );
  }
}
