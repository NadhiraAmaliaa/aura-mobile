import 'package:flutter/widgets.dart';

/// Adaptive breakpoints shared by every Home section, so they all switch
/// composition at the same text scale instead of each guessing its own.
abstract final class HomeLayout {
  /// Horizontal page gutter: slightly tighter on very narrow phones.
  static double gutter(double screenWidth) => screenWidth < 360 ? 16 : 18;

  /// Effective text scale for body-sized text. Measured at 14sp because
  /// Android's non-linear font scaling enlarges small text more than large.
  static double textFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(14) / 14;

  /// Whether side-by-side compositions should stack vertically.
  static bool largeText(BuildContext context) => textFactor(context) > 1.35;
}
