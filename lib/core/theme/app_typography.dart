import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale for Illustrated Life Journal.
///
/// Display/headline text uses "Fraunces", an elegant serif with warm,
/// slightly storybook character. Supporting text uses "Inter", a clean,
/// highly legible sans-serif, so the UI stays readable while the serif
/// carries the premium/cinematic feeling.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final base = TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.charcoalSoft,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.charcoalSoft,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.charcoalFaint,
      ),
    );
    return base;
  }
}
