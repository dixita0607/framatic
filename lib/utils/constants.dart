import 'package:framatic/models/frame_preset.dart';
import 'package:uuid/uuid.dart';

/// Predefined aspect ratios for framing
class AspectRatios {
  /// List of predefined frame presets (minimal defaults)
  /// Additional ratios can be added by users as custom presets
  static List<FramePreset> get predefinedFrames => [
    FramePreset(name: '16:9', width: 16, height: 9, id: const Uuid().v4(), isCustom: false),
    FramePreset(name: '4:3', width: 4, height: 3, id: const Uuid().v4(), isCustom: false),
    FramePreset(name: '1:1', width: 1, height: 1, id: const Uuid().v4(), isCustom: false),
  ];
}

/// App-wide constants
class AppConstants {
  static const String appName = 'Framatic';
  static const String galleryAlbumName = 'Framatic';

  // Frame overlay settings
  static const double minFramePadding = 0.05; // 5% of screen
  static const double maxFramePadding = 0.95; // 95% of screen

  // Polaroid border width (used in both preview and saved photos)
  static const double frameBorderWidth = 16.0;
}
