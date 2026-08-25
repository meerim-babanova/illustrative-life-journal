import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../journal/data/scene_interpreter.dart';
import '../../../journal/presentation/widgets/scene_art.dart';
import '../../models/story.dart';

/// A Story tile. Its cover is now a real illustration, interpreted from the
/// story's own title, so Stories looks like a shelf of illustrated chapters.
///
/// The cover has a fixed height and the text clips — the old
/// AspectRatio-inside-a-fixed-ratio-grid combination is what produced the
/// yellow overflow stripes on Stories.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.coverHeight = 124,
  });

  final Story story;
  final VoidCallback? onTap;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scene = const SceneInterpreter()
        .interpret(story.title, seed: (story.coverColorSeed ?? 0) * 977 + 13);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: coverHeight,
                width: double.infinity,
                child: SceneArt(scene: scene, borderRadius: AppRadius.lg),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.title,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      story.entryCount.toString() +
                          (story.entryCount == 1 ? ' memory' : ' memories'),
                      style: textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
