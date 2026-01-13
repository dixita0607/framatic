import 'package:flutter/material.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/utils/constants.dart';

/// Widget that displays a frame overlay over the camera preview
class FrameOverlay extends StatelessWidget {
  final FramePreset preset;
  final double opacity;

  const FrameOverlay({
    super.key,
    required this.preset,
    this.opacity = AppConstants.defaultFrameOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FrameOverlayPainter(
        preset: preset,
        opacity: opacity,
      ),
      child: Container(),
    );
  }
}

/// Custom painter for drawing the frame overlay
class FrameOverlayPainter extends CustomPainter {
  final FramePreset preset;
  final double opacity;

  FrameOverlayPainter({
    required this.preset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = preset.frameColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Calculate frame dimensions based on aspect ratio
    final frameSize = _calculateFrameSize(size);
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize.width,
      height: frameSize.height,
    );

    // Create path for the overlay (everything except the frame area)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(frameRect)
      ..fillType = PathFillType.evenOdd;

    // Draw the solid white overlay outside the frame
    canvas.drawPath(path, paint);

    // Draw frame border (thin line to define frame edge)
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(frameRect, borderPaint);

    // Optionally draw aspect ratio label
    _drawLabel(canvas, size, frameRect);
  }

  /// Calculate frame size that fits within the screen while maintaining aspect ratio
  Size _calculateFrameSize(Size screenSize) {
    double frameWidth = screenSize.width * AppConstants.maxFramePadding;
    double frameHeight = frameWidth / preset.aspectRatio;

    // If height exceeds screen bounds, scale based on height instead
    if (frameHeight > screenSize.height * AppConstants.maxFramePadding) {
      frameHeight = screenSize.height * AppConstants.maxFramePadding;
      frameWidth = frameHeight * preset.aspectRatio;
    }

    return Size(frameWidth, frameHeight);
  }

  /// Draw aspect ratio label at bottom of frame
  void _drawLabel(Canvas canvas, Size screenSize, Rect frameRect) {
    final textSpan = TextSpan(
      text: preset.name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position label at bottom center of frame
    final offset = Offset(
      frameRect.center.dx - textPainter.width / 2,
      frameRect.bottom + 12,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(FrameOverlayPainter oldDelegate) {
    return oldDelegate.preset != preset || oldDelegate.opacity != opacity;
  }
}
