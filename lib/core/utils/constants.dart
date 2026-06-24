/// App-wide constants
class AppConstants {
  static const String appName = 'Framatic';

  /// Per-side frame border as a fraction of the inner image's longest side.
  static const double frameBorderRatio = 0.04;

  /// Prevents the border from overwhelming very narrow frames.
  static const double maxFrameBorderShortSideRatio = 0.08;

  /// Gives the handwritten ratio enough room without turning the frame into a
  /// heavy Polaroid-style border.
  static const double frameBottomBorderMultiplier = 1.55;

  static const int paperRed = 255;
  static const int paperGreen = 253;
  static const int paperBlue = 247;
}
