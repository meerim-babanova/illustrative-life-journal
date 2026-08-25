import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../character/models/character_config.dart';
import '../../../character/presentation/widgets/character_preview.dart';

/// The illustration-generation waiting experience.
///
/// Design intent: this should feel like watching a page slowly come to
/// life in a storybook, not like a technical progress bar. Two things
/// carry that feeling:
///
/// 1. A slow "breathing" glow behind the user's own character (scale +
///    opacity, ~2.6s per cycle, eased in and out) — an indeterminate
///    animation with no percentage, per the design brief.
/// 2. A second line of reassurance that gently crossfades in after a
///    pause, so a longer wait reads as attentive rather than stuck.
class GenerationPulse extends StatefulWidget {
  const GenerationPulse({super.key, required this.character});

  final CharacterConfig character;

  @override
  State<GenerationPulse> createState() => _GenerationPulseState();
}

class _GenerationPulseState extends State<GenerationPulse>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Turning your memory into an illustration…',
    'Finding the little details that make this moment yours.',
    'Almost there — good stories take a moment to draw.',
  ];

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  int _messageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    // The first message shows immediately; later ones rotate slowly so the
    // wait feels narrated rather than stalled. Guarded by `mounted` since
    // generation can finish (and this widget be disposed) before a later
    // tick would otherwise fire.
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, child) {
              // Ease the linear 0..1 controller value into a gentle
              // in-and-out curve rather than a linear pulse.
              final t = Curves.easeInOut.transform(_breath.value);
              final glowScale = 0.92 + (t * 0.16);
              final glowOpacity = 0.18 + (t * 0.22);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: glowScale,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coral.withValues(alpha: glowOpacity),
                      ),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: CharacterPreview(config: widget.character, size: 150),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _messages[_messageIndex],
            key: ValueKey(_messageIndex),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
