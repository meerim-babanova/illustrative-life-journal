import 'package:flutter/material.dart';

/// Central color palette for Illustrated Life Journal.
///
/// The palette is intentionally warm and muted — ivory backgrounds, warm
/// charcoal text, earthy accents, and a single warm coral highlight — to
/// support the "personal illustrated storybook" feeling described in the
/// product spec, rather than a bright, generic app look.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color ivory = Color(0xFFFBF5EC);
  static const Color ivoryDim = Color(0xFFF3EAD9);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color charcoal = Color(0xFF2E2A26);
  static const Color charcoalSoft = Color(0xFF5B554D);
  static const Color charcoalFaint = Color(0xFF948C80);

  // Earthy accents
  static const Color sage = Color(0xFF8A9A7E);
  static const Color taupe = Color(0xFFA98F72);
  static const Color clay = Color(0xFFC98F6C);

  // Primary warm accent
  static const Color coral = Color(0xFFE88C7D);
  static const Color coralDeep = Color(0xFFD97764);

  // Utility
  static const Color divider = Color(0xFFE7DDCB);
  static const Color shadow = Color(0x1F2E2A26);

  /// A small rotating set of muted colors used for placeholder character
  /// illustrations and story cover placeholders, so mock content still
  /// feels intentional rather than randomly colored.
  static const List<Color> placeholderPalette = [
    sage,
    taupe,
    clay,
    coral,
  ];
}
