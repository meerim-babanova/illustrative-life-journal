import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/journal_page.dart';
import 'scene_art.dart';

/// A recent memory on Home: its illustration, its date, its own words.
///
/// Heights are intrinsic (a fixed-height cover plus text that clips), so the
/// card cannot overflow at any width — the Phase 1 version used a fixed
/// 90px row and produced overflow stripes.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.page,
    this.coverHeight = 132,
    this.onTap,
  });

  final JournalPage page;
  final double coverHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
            color: AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: coverHeight,
                width: double.infinity,
                child: SceneArt(scene: page.scene, borderRadius: AppRadius.lg),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_shortDate(page.date).toUpperCase(),
                        style:
                            textTheme.labelSmall?.copyWith(letterSpacing: 1.4)),
                    const SizedBox(height: 2),
                    Text(
                      page.title,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      page.text,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
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

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return d.day.toString() + ' ' + months[d.month - 1];
  }
}
