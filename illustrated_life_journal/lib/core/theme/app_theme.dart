import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Shared spacing and radius constants so screens don't hardcode magic
/// numbers. Values are logical pixels and scale naturally with text/media
/// query settings — no fixed device dimensions are assumed anywhere.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999;
}

/// Deterministic sizes for components whose height must NOT depend on
/// available width (the root cause of the Home/Stories card overflow: a
/// width-proportional `AspectRatio` cover combined with variable-width
/// text produced an unpredictable total height that occasionally exceeded
/// its fixed-height parent). Every card that uses these constants gets the
/// same, guaranteed-to-fit height regardless of column/viewport width.
class AppSizes {
  AppSizes._();

  /// Cover image/placeholder height inside a [StoryCard] — fixed in
  /// pixels rather than proportional to card width, so it never grows
  /// large enough (at wide card widths) to push the text below it past
  /// the card's total height.
  static const double storyCoverHeight = 96;

  /// Text block height inside a [StoryCard] (title + count), fixed so the
  /// card's total height is fully deterministic and independent of font
  /// metrics or text-scale factor edge cases.
  static const double storyTextBlockHeight = 56;

  /// Total [StoryCard] height: cover + text block + vertical padding.
  /// Used both by Home's horizontal story strip and the Stories grid, so
  /// the two can never drift out of sync.
  static const double storyCardHeight =
      storyCoverHeight + storyTextBlockHeight + (AppSpacing.md * 2);

  /// Width used for [StoryCard] instances in horizontal scrolling strips.
  static const double storyCardWidth = 160;

  /// Fixed total height/width for the Recent Memories card on Home, for
  /// the same determinism reason as the story card sizes above.
  static const double memoryCardHeight = 96;
  static const double memoryCardWidth = 220;
}

/// Breakpoints for the small number of places that need to adapt layout
/// to viewport width (Section 5: desktop, laptop, tablet, and narrow web
/// viewports). Kept intentionally minimal — most of the app already
/// reflows naturally via `Expanded`/`Wrap`/scroll views and doesn't need
/// explicit breakpoints at all.
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 480;
  static const double medium = 720;
  static const double wide = 1080;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        titleTextStyle: textTheme.titleMedium,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.charcoalSoft,
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.coralDeep,
        unselectedItemColor: AppColors.charcoalFaint,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
