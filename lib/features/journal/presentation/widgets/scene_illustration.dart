import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
import '../../models/illustration_scene.dart';
import 'scene_art.dart';

/// The illustration as the user sees it: the painted scene with their own
/// character standing in it.
///
/// Character consistency comes for free here — the figure is rendered from
/// the saved [CharacterConfig], the same source the Character Studio edits,
/// so every page in the journal shows the same person.
class SceneIllustration extends StatelessWidget {
  const SceneIllustration({
    super.key,
    required this.scene,
    this.borderRadius = 24,
    this.showCharacter = true,
    this.characterScale = 0.46,
  });

  final IllustrationScene scene;
  final double borderRadius;
  final bool showCharacter;

  /// Character height as a fraction of the illustration height.
  final double characterScale;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<CharacterProvider>().config;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth * 0.5625;
        return Stack(
          fit: StackFit.expand,
          children: [
            SceneArt(scene: scene, borderRadius: borderRadius),
            if (showCharacter)
              Align(
                alignment: const Alignment(0, 0.62),
                child: CharacterPreview(
                  config: config,
                  size: h * characterScale,
                ),
              ),
          ],
        );
      },
    );
  }
}
