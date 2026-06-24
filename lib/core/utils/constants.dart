/// App-wide constants
class AppConstants {
  static const String appName = 'Framatic';

  /// Per-side frame border as a fraction of the inner image's longest side.
  static const double frameBorderRatio = 0.04;

  /// Prevents the border from overwhelming very narrow frames.
  static const double maxFrameBorderShortSideRatio = 0.08;
}
