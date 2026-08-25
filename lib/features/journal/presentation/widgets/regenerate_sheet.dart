import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/illustration_scene.dart';
import 'scene_art.dart';

/// The Regenerate interaction: a calm sheet over the page, optional nudges,
/// and every earlier take kept so nothing the user liked can be lost.
class RegenerateResult {
  const RegenerateResult({this.nudge, this.restore});

  /// A nudge label, or null for "just draw it again".
  final String? nudge;

  /// A take to go back to instead of drawing something new.
  final IllustrationScene? restore;
}

Future<RegenerateResult?> showRegenerateSheet(
  BuildContext context, {
  required List<IllustrationScene> takes,
}) {
  return showModalBottomSheet<RegenerateResult>(
    context: context,
    backgroundColor: AppColors.ivory,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => _RegenerateSheet(takes: takes),
  );
}

class _RegenerateSheet extends StatefulWidget {
  const _RegenerateSheet({required this.takes});

  final List<IllustrationScene> takes;

  @override
  State<_RegenerateSheet> createState() => _RegenerateSheetState();
}

class _RegenerateSheetState extends State<_RegenerateSheet> {
  static const _nudges = [
    'Golden hour',
    'Quieter',
    'More people',
    'Wider scene',
    'Closer in',
  ];
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Try a different illustration?',
                            style: textTheme.headlineSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your character and your words stay exactly the same — only the drawing changes.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.charcoalFaint),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('NUDGE THE FEELING (OPTIONAL)',
                  style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final n in _nudges)
                    _NudgeChip(
                      label: n,
                      selected: _selected == n,
                      onTap: () => setState(
                          () => _selected = _selected == n ? null : n),
                    ),
                ],
              ),
              if (widget.takes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('EARLIER TAKES',
                    style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.takes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final take = widget.takes[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pop(RegenerateResult(restore: take)),
                        child: SizedBox(
                          width: 84,
                          child: SceneArt(scene: take, borderRadius: 14),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Nothing is thrown away — tap a take to go back to it.',
                    style: textTheme.labelSmall),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Draw it again',
                icon: Icons.refresh,
                onPressed: () => Navigator.of(context)
                    .pop(RegenerateResult(nudge: _selected)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NudgeChip extends StatelessWidget {
  const _NudgeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: selected ? AppColors.coral : AppColors.divider),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.surface : AppColors.charcoalSoft,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
