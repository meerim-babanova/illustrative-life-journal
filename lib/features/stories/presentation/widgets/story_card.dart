import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/story.dart';

/// A single Story tile: a placeholder color cover, title, and entry count.
class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story, this.onTap});

  final Story story;
  final VoidCallback? onTap;

  Color _coverColor() {
    final palette = AppColors.placeholderPalette;
    final index = (story.coverColorSeed ?? 0) % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                color: _coverColor().withOpacity(0.35),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                color: _coverColor(),
                size: 36,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
