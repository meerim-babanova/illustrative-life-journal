import 'package:flutter/widgets.dart';

/// Single source of truth for the responsive tiers used in Phase 2.
///
/// Phase 1 assumed a phone-sized viewport everywhere. Phase 2 screens are
/// laid out from these tiers instead of hardcoded widths, which is also
/// what removes the fixed-height/fixed-aspect overflows.
enum Tier { narrow, tablet, laptop, desktop }

class Breakpoints {
  Breakpoints._();

  static const double tablet = 700;
  static const double laptop = 1000;
  static const double desktop = 1320;

  static Tier of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static Tier fromWidth(double width) {
    if (width >= desktop) return Tier.desktop;
    if (width >= laptop) return Tier.laptop;
    if (width >= tablet) return Tier.tablet;
    return Tier.narrow;
  }

  /// Journal/write screens switch from stacked to two-column here.
  static bool isWide(BuildContext context) {
    final tier = of(context);
    return tier == Tier.laptop || tier == Tier.desktop;
  }

  /// Comfortable reading measure: the page never stretches edge to edge on
  /// a large display.
  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case Tier.desktop:
        return 1180;
      case Tier.laptop:
        return 980;
      case Tier.tablet:
        return 760;
      case Tier.narrow:
        return 560;
    }
  }

  /// Grid column count that adapts instead of relying on a fixed tile
  /// aspect ratio (the cause of the Stories overflow stripes).
  static int gridColumns(BuildContext context, {int max = 4}) {
    switch (of(context)) {
      case Tier.desktop:
        return max;
      case Tier.laptop:
        return max > 3 ? 3 : max;
      case Tier.tablet:
        return 2;
      case Tier.narrow:
        return 1;
    }
  }
}
