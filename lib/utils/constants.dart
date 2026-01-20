import 'package:framatic/models/frame_preset.dart';

/// Predefined aspect ratios for framing
class AspectRatios {
  static const double ratio4x3 = 4 / 3;
  static const double ratio16x9 = 16 / 9;
  static const double ratio1x1 = 1 / 1;
  static const double ratio3x2 = 3 / 2;
  static const double ratio2x3 = 2 / 3;
  static const double ratio5x7 = 5 / 7;
  static const double goldenRatio = 1.618;

  /// List of predefined frame presets
  static List<FramePreset> get predefinedFrames => [
        FramePreset(
          name: '4:3',
          aspectRatio: ratio4x3,
          isCustom: false,
        ),
        FramePreset(
          name: '16:9',
          aspectRatio: ratio16x9,
          isCustom: false,
        ),
        FramePreset(
          name: '1:1',
          aspectRatio: ratio1x1,
          isCustom: false,
        ),
        FramePreset(
          name: '3:2',
          aspectRatio: ratio3x2,
          isCustom: false,
        ),
        FramePreset(
          name: '2:3',
          aspectRatio: ratio2x3,
          isCustom: false,
        ),
        FramePreset(
          name: '5:7',
          aspectRatio: ratio5x7,
          isCustom: false,
        ),
        FramePreset(
          name: 'Golden',
          aspectRatio: goldenRatio,
          isCustom: false,
        ),
      ];
}

/// App-wide constants
class AppConstants {
  static const String appName = 'Framatic';
  static const String galleryAlbumName = 'Artist Frames';

  // Frame overlay settings
  static const double defaultFrameOpacity = 0.9;
  static const double minFramePadding = 0.05; // 5% of screen
  static const double maxFramePadding = 0.95; // 95% of screen

  // Polaroid border width (used in both preview and saved photos)
  static const double frameBorderWidth = 32.0;
  static const int frameBorderWidthInt = 32; // For image processing
}
