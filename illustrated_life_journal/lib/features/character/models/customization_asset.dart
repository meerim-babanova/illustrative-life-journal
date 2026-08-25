import 'package:flutter/material.dart';

/// The customization categories available in the Character Studio.
///
/// New categories can be added here without touching the studio screen's
/// layout code, since the UI renders tabs and options from data (see
/// [CustomizationAsset] and the catalog below).
enum CustomizationCategory { face, eyes, hair, skin, body, clothes, accessories }

extension CustomizationCategoryX on CustomizationCategory {
  String get label {
    switch (this) {
      case CustomizationCategory.face:
        return 'Face';
      case CustomizationCategory.eyes:
        return 'Eyes';
      case CustomizationCategory.hair:
        return 'Hair';
      case CustomizationCategory.skin:
        return 'Skin';
      case CustomizationCategory.body:
        return 'Body';
      case CustomizationCategory.clothes:
        return 'Clothes';
      case CustomizationCategory.accessories:
        return 'Accessories';
    }
  }
}

/// A single selectable customization option.
///
/// [previewAsset] and [renderingAsset] hold *identifiers* rather than
/// concrete file paths. For Phase 1, before real illustrated art exists,
/// these identifiers are interpreted by the placeholder preview renderer
/// (a color + shape hint). Once real art assets are produced, these same
/// identifiers can point at actual asset paths without changing this model
/// or the screens that consume it.
class CustomizationAsset {
  const CustomizationAsset({
    required this.id,
    required this.category,
    required this.name,
    required this.previewAsset,
    required this.renderingAsset,
    this.metadata = const {},
    this.swatch,
  });

  final String id;
  final CustomizationCategory category;
  final String name;
  final String previewAsset;
  final String renderingAsset;
  final Map<String, dynamic> metadata;

  /// Optional color used only for the Phase 1 placeholder preview (e.g. a
  /// hair color or skin tone swatch). Not part of the "real" asset model —
  /// purely a rendering convenience until illustrated assets exist.
  final Color? swatch;
}
