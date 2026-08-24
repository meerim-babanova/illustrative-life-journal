import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/customization_catalog.dart';
import '../../models/character_config.dart';
import '../../models/customization_asset.dart';

/// Renders a simple, storybook-flavored placeholder illustration of the
/// user's character, driven entirely by [CharacterConfig].
///
/// This is explicitly NOT the final illustrated art (see spec Section 1:
/// "the actual character artwork may initially be represented by
/// placeholders"). It exists so the character feels present and reactive
/// while customizing, without depending on any image generation provider.
/// When Phase 5/6 introduce real illustrated rendering, this widget can be
/// swapped for an `Image`/asset-based renderer without changing anything
/// that consumes [CharacterPreview].
class CharacterPreview extends StatelessWidget {
  const CharacterPreview({
    super.key,
    required this.config,
    this.size = 220,
  });

  final CharacterConfig config;
  final double size;

  static const Map<String, Color> _eyeColorSwatches = {
    'brown': Color(0xFF6B4A2F),
    'hazel': Color(0xFF8A7443),
    'green': Color(0xFF6E8F5C),
    'blue': Color(0xFF5C7A94),
    'gray': Color(0xFF8C8C8C),
  };

  Color _skinColor() {
    final match = CustomizationCatalog.byCategory(CustomizationCategory.skin)
        .where((a) => a.renderingAsset.contains(config.skinTone))
        .toList();
    return match.isNotEmpty && match.first.swatch != null
        ? match.first.swatch!
        : const Color(0xFFE9C4A0);
  }

  Color _hairColorValue() {
    final match = CustomizationCatalog.byCategory(CustomizationCategory.hair)
        .where((a) => a.renderingAsset.contains(config.hairStyle))
        .toList();
    return match.isNotEmpty && match.first.swatch != null
        ? match.first.swatch!
        : const Color(0xFF4A3223);
  }

  Color _outfitColor() {
    final match =
        CustomizationCatalog.byCategory(CustomizationCategory.clothes)
            .where((a) => a.renderingAsset.contains(config.outfitTop))
            .toList();
    return match.isNotEmpty && match.first.swatch != null
        ? match.first.swatch!
        : AppColors.sage;
  }

  BorderRadius _headRadius() {
    switch (config.headShape) {
      case 'square':
        return BorderRadius.circular(size * 0.12);
      case 'heart':
        return BorderRadius.only(
          topLeft: Radius.circular(size * 0.32),
          topRight: Radius.circular(size * 0.32),
          bottomLeft: Radius.circular(size * 0.12),
          bottomRight: Radius.circular(size * 0.12),
        );
      case 'long':
        return BorderRadius.circular(size * 0.28);
      case 'oval':
        return BorderRadius.circular(size * 0.34);
      default: // round, petite, wide, narrow -> soft rounded default
        return BorderRadius.circular(size * 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = _skinColor();
    final hair = _hairColorValue();
    final outfit = _outfitColor();
    final headHeightFactor = config.headShape == 'long' ? 0.62 : 0.52;

    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Body / outfit
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.72,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: outfit,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.22),
                  topRight: Radius.circular(size * 0.22),
                  bottomLeft: Radius.circular(size * 0.14),
                  bottomRight: Radius.circular(size * 0.14),
                ),
              ),
            ),
          ),
          // Head / face
          Positioned(
            bottom: size * 0.42,
            child: Container(
              width: size * 0.62,
              height: size * headHeightFactor,
              decoration: BoxDecoration(
                color: skin,
                borderRadius: _headRadius(),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Eyes
                  Positioned(
                    top: size * headHeightFactor * 0.42,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _eye(config.eyeShape, config.eyeColor),
                        SizedBox(width: size * 0.09),
                        _eye(config.eyeShape, config.eyeColor),
                      ],
                    ),
                  ),
                  // Mouth
                  Positioned(
                    bottom: size * headHeightFactor * 0.18,
                    child: Container(
                      width: size * 0.14,
                      height: size * 0.03,
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSoft,
                        borderRadius: BorderRadius.circular(size * 0.02),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hair (rendered above the head so the style silhouette reads)
          Positioned(
            bottom: size * (headHeightFactor + 0.42) * 0.86,
            child: Container(
              width: size * (config.hairStyle.contains('long') ? 0.74 : 0.66),
              height: size *
                  (config.hairStyle.contains('long')
                      ? 0.42
                      : config.hairStyle == 'pixie'
                          ? 0.22
                          : 0.3),
              decoration: BoxDecoration(
                color: hair,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.36),
                  topRight: Radius.circular(size * 0.36),
                  bottomLeft: Radius.circular(size * 0.18),
                  bottomRight: Radius.circular(size * 0.18),
                ),
              ),
            ),
          ),
          if (config.accessories.contains('acc_glasses'))
            Positioned(
              bottom: size * (headHeightFactor + 0.42) * 0.58,
              child: Container(
                width: size * 0.34,
                height: size * 0.06,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.charcoal, width: 1.5),
                  borderRadius: BorderRadius.circular(size * 0.03),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _eye(String shape, String colorId) {
    final color = _eyeColorSwatches[colorId] ?? const Color(0xFF6B4A2F);
    final isNarrow = shape == 'almond' || shape == 'wide';
    return Container(
      width: size * (isNarrow ? 0.075 : 0.06),
      height: size * (isNarrow ? 0.04 : 0.06),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.03),
      ),
    );
  }
}
