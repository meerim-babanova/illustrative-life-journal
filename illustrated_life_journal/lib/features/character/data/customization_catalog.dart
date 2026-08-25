import 'package:flutter/material.dart';

import '../models/customization_asset.dart';

/// Phase 1 customization catalog.
///
/// This is a hand-authored, in-memory catalog so the Character Studio has
/// enough options to demonstrate the interaction end-to-end. It deliberately
/// mirrors the shape a future remote/asset-driven catalog would have
/// (grouped by [CustomizationCategory], one flat list of [CustomizationAsset]
/// items) so the studio screen never needs to change when hundreds of real
/// assets are added later — only this data source does.
class CustomizationCatalog {
  CustomizationCatalog._();

  static const List<CustomizationAsset> all = [
    // Face
    CustomizationAsset(
      id: 'face_round',
      category: CustomizationCategory.face,
      name: 'Round',
      previewAsset: 'face/round',
      renderingAsset: 'face/round',
    ),
    CustomizationAsset(
      id: 'face_oval',
      category: CustomizationCategory.face,
      name: 'Oval',
      previewAsset: 'face/oval',
      renderingAsset: 'face/oval',
    ),
    CustomizationAsset(
      id: 'face_square',
      category: CustomizationCategory.face,
      name: 'Square',
      previewAsset: 'face/square',
      renderingAsset: 'face/square',
    ),
    CustomizationAsset(
      id: 'face_heart',
      category: CustomizationCategory.face,
      name: 'Heart',
      previewAsset: 'face/heart',
      renderingAsset: 'face/heart',
    ),
    CustomizationAsset(
      id: 'face_long',
      category: CustomizationCategory.face,
      name: 'Long',
      previewAsset: 'face/long',
      renderingAsset: 'face/long',
    ),
    CustomizationAsset(
      id: 'face_petite',
      category: CustomizationCategory.face,
      name: 'Petite',
      previewAsset: 'face/petite',
      renderingAsset: 'face/petite',
    ),

    // Eyes (color used for the placeholder preview)
    CustomizationAsset(
      id: 'eyes_brown',
      category: CustomizationCategory.eyes,
      name: 'Brown',
      previewAsset: 'eyes/round',
      renderingAsset: 'eyes/round',
      swatch: Color(0xFF6B4A2F),
    ),
    CustomizationAsset(
      id: 'eyes_hazel',
      category: CustomizationCategory.eyes,
      name: 'Hazel',
      previewAsset: 'eyes/round',
      renderingAsset: 'eyes/round',
      swatch: Color(0xFF8A7443),
    ),
    CustomizationAsset(
      id: 'eyes_green',
      category: CustomizationCategory.eyes,
      name: 'Green',
      previewAsset: 'eyes/almond',
      renderingAsset: 'eyes/almond',
      swatch: Color(0xFF6E8F5C),
    ),
    CustomizationAsset(
      id: 'eyes_blue',
      category: CustomizationCategory.eyes,
      name: 'Blue',
      previewAsset: 'eyes/almond',
      renderingAsset: 'eyes/almond',
      swatch: Color(0xFF5C7A94),
    ),
    CustomizationAsset(
      id: 'eyes_gray',
      category: CustomizationCategory.eyes,
      name: 'Gray',
      previewAsset: 'eyes/wide',
      renderingAsset: 'eyes/wide',
      swatch: Color(0xFF8C8C8C),
    ),

    // Hair (style + color used for placeholder preview)
    CustomizationAsset(
      id: 'hair_bob',
      category: CustomizationCategory.hair,
      name: 'Bob',
      previewAsset: 'hair/bob',
      renderingAsset: 'hair/bob',
      swatch: Color(0xFF3B2A20),
    ),
    CustomizationAsset(
      id: 'hair_long_straight',
      category: CustomizationCategory.hair,
      name: 'Long straight',
      previewAsset: 'hair/long_straight',
      renderingAsset: 'hair/long_straight',
      swatch: Color(0xFF4A3223),
    ),
    CustomizationAsset(
      id: 'hair_long_wavy',
      category: CustomizationCategory.hair,
      name: 'Long wavy',
      previewAsset: 'hair/long_wavy',
      renderingAsset: 'hair/long_wavy',
      swatch: Color(0xFF6B4A2F),
    ),
    CustomizationAsset(
      id: 'hair_curly',
      category: CustomizationCategory.hair,
      name: 'Curly',
      previewAsset: 'hair/curly',
      renderingAsset: 'hair/curly',
      swatch: Color(0xFF2E2018),
    ),
    CustomizationAsset(
      id: 'hair_ponytail',
      category: CustomizationCategory.hair,
      name: 'Ponytail',
      previewAsset: 'hair/ponytail',
      renderingAsset: 'hair/ponytail',
      swatch: Color(0xFF5A3A22),
    ),
    CustomizationAsset(
      id: 'hair_braids',
      category: CustomizationCategory.hair,
      name: 'Braids',
      previewAsset: 'hair/braids',
      renderingAsset: 'hair/braids',
      swatch: Color(0xFF3B2A20),
    ),
    CustomizationAsset(
      id: 'hair_pixie',
      category: CustomizationCategory.hair,
      name: 'Pixie',
      previewAsset: 'hair/pixie',
      renderingAsset: 'hair/pixie',
      swatch: Color(0xFF1F1B18),
    ),
    CustomizationAsset(
      id: 'hair_shoulder_bangs',
      category: CustomizationCategory.hair,
      name: 'Shoulder-length bangs',
      previewAsset: 'hair/shoulder_bangs',
      renderingAsset: 'hair/shoulder_bangs',
      swatch: Color(0xFF6B4A2F),
    ),

    // Skin tone
    CustomizationAsset(
      id: 'skin_porcelain',
      category: CustomizationCategory.skin,
      name: 'Porcelain',
      previewAsset: 'skin/porcelain',
      renderingAsset: 'skin/porcelain',
      swatch: Color(0xFFF3D8C0),
    ),
    CustomizationAsset(
      id: 'skin_light',
      category: CustomizationCategory.skin,
      name: 'Light',
      previewAsset: 'skin/light',
      renderingAsset: 'skin/light',
      swatch: Color(0xFFE9C4A0),
    ),
    CustomizationAsset(
      id: 'skin_medium',
      category: CustomizationCategory.skin,
      name: 'Medium',
      previewAsset: 'skin/medium',
      renderingAsset: 'skin/medium',
      swatch: Color(0xFFCF9A6C),
    ),
    CustomizationAsset(
      id: 'skin_tan',
      category: CustomizationCategory.skin,
      name: 'Tan',
      previewAsset: 'skin/tan',
      renderingAsset: 'skin/tan',
      swatch: Color(0xFFAD7647),
    ),
    CustomizationAsset(
      id: 'skin_deep',
      category: CustomizationCategory.skin,
      name: 'Deep',
      previewAsset: 'skin/deep',
      renderingAsset: 'skin/deep',
      swatch: Color(0xFF7A4E2E),
    ),

    // Body type
    CustomizationAsset(
      id: 'body_slim',
      category: CustomizationCategory.body,
      name: 'Slim',
      previewAsset: 'body/slim',
      renderingAsset: 'body/slim',
    ),
    CustomizationAsset(
      id: 'body_average',
      category: CustomizationCategory.body,
      name: 'Average',
      previewAsset: 'body/average',
      renderingAsset: 'body/average',
    ),
    CustomizationAsset(
      id: 'body_curvy',
      category: CustomizationCategory.body,
      name: 'Curvy',
      previewAsset: 'body/curvy',
      renderingAsset: 'body/curvy',
    ),
    CustomizationAsset(
      id: 'body_broad',
      category: CustomizationCategory.body,
      name: 'Broad',
      previewAsset: 'body/broad',
      renderingAsset: 'body/broad',
    ),

    // Clothes (top color used for placeholder preview)
    CustomizationAsset(
      id: 'outfit_cream_sweater',
      category: CustomizationCategory.clothes,
      name: 'Cream sweater',
      previewAsset: 'clothes/cream_sweater',
      renderingAsset: 'clothes/cream_sweater',
      swatch: Color(0xFFEFE3CE),
    ),
    CustomizationAsset(
      id: 'outfit_green_cardigan',
      category: CustomizationCategory.clothes,
      name: 'Green cardigan',
      previewAsset: 'clothes/green_cardigan',
      renderingAsset: 'clothes/green_cardigan',
      swatch: Color(0xFF7C8F6A),
    ),
    CustomizationAsset(
      id: 'outfit_brown_jacket',
      category: CustomizationCategory.clothes,
      name: 'Brown jacket',
      previewAsset: 'clothes/brown_jacket',
      renderingAsset: 'clothes/brown_jacket',
      swatch: Color(0xFF7A5B3D),
    ),
    CustomizationAsset(
      id: 'outfit_black_dress',
      category: CustomizationCategory.clothes,
      name: 'Black dress',
      previewAsset: 'clothes/black_dress',
      renderingAsset: 'clothes/black_dress',
      swatch: Color(0xFF2B2B2B),
    ),

    // Accessories
    CustomizationAsset(
      id: 'acc_glasses',
      category: CustomizationCategory.accessories,
      name: 'Glasses',
      previewAsset: 'accessories/glasses',
      renderingAsset: 'accessories/glasses',
    ),
    CustomizationAsset(
      id: 'acc_headphones',
      category: CustomizationCategory.accessories,
      name: 'Headphones',
      previewAsset: 'accessories/headphones',
      renderingAsset: 'accessories/headphones',
    ),
    CustomizationAsset(
      id: 'acc_cap',
      category: CustomizationCategory.accessories,
      name: 'Cap',
      previewAsset: 'accessories/cap',
      renderingAsset: 'accessories/cap',
    ),
    CustomizationAsset(
      id: 'acc_shoulder_bag',
      category: CustomizationCategory.accessories,
      name: 'Shoulder bag',
      previewAsset: 'accessories/shoulder_bag',
      renderingAsset: 'accessories/shoulder_bag',
    ),
  ];

  static List<CustomizationAsset> byCategory(CustomizationCategory category) =>
      all.where((a) => a.category == category).toList(growable: false);
}
