import 'package:flutter/material.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/utils/constants.dart';

/// Widget that displays a polaroid-style frame border over the camera preview
class FrameOverlay extends StatelessWidget {
  final Frame preset;
  final double borderWidth;
  final double? maxHeight;

  const FrameOverlay({
    super.key,
    required this.preset,
    this.borderWidth = AppConstants.frameBorderThickness,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FrameOverlayPainter(
        preset: preset,
        borderWidth: borderWidth,
        maxHeight: maxHeight,
      ),
      child: Container(),
    );
  }
}

/// Custom painter for drawing the polaroid-style frame border
class FrameOverlayPainter extends CustomPainter {
  final Frame preset;
  final double borderWidth;
  final double? maxHeight;

  FrameOverlayPainter({
    required this.preset,
    required this.borderWidth,
    this.maxHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate frame dimensions based on aspect ratio
    final frameSize = _calculateFrameSize(size);
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize.width,
      height: frameSize.height,
    );

    // Draw solid white border using filled rectangles for consistent thickness
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Top border
    canvas.drawRect(
      Rect.fromLTRB(
        frameRect.left - borderWidth,
        frameRect.top - borderWidth,
        frameRect.right + borderWidth,
        frameRect.top,
      ),
      borderPaint,
    );

    // Bottom border
    canvas.drawRect(
      Rect.fromLTRB(
        frameRect.left - borderWidth,
        frameRect.bottom,
        frameRect.right + borderWidth,
        frameRect.bottom + borderWidth,
      ),
      borderPaint,
    );

    // Left border
    canvas.drawRect(
      Rect.fromLTRB(
        frameRect.left - borderWidth,
        frameRect.top,
        frameRect.left,
        frameRect.bottom,
      ),
      borderPaint,
    );

    // Right border
    canvas.drawRect(
      Rect.fromLTRB(
        frameRect.right,
        frameRect.top,
        frameRect.right + borderWidth,
        frameRect.bottom,
      ),
      borderPaint,
    );

    // Draw aspect ratio label above frame
    _drawLabel(canvas, size, frameRect);
  }

  /// Calculate frame size that fits within the screen while maintaining aspect ratio
  /// Accounts for border width so the border doesn't get clipped
  Size _calculateFrameSize(Size screenSize) {
    // Available space after accounting for border on both sides
    final availableWidth =
        screenSize.width * AppConstants.maxFramePadding - (borderWidth * 2);
    // Use maxHeight if provided (for camera area with fixed height), otherwise use screen height
    final heightConstraint = maxHeight ?? screenSize.height;
    final availableHeight =
        heightConstraint * AppConstants.maxFramePadding - (borderWidth * 2);

    double frameWidth = availableWidth;
    double frameHeight = frameWidth / preset.aspectRatio;

    // If height exceeds available bounds, scale based on height instead
    if (frameHeight > availableHeight) {
      frameHeight = availableHeight;
      frameWidth = frameHeight * preset.aspectRatio;
    }

    return Size(frameWidth, frameHeight);
  }

  /// Draw aspect ratio label at top of frame
  void _drawLabel(Canvas canvas, Size screenSize, Rect frameRect) {
    final textSpan = TextSpan(
      text: preset.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 3),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position label above the border
    final offset = Offset(
      frameRect.center.dx - textPainter.width / 2,
      frameRect.top - borderWidth - 8 - textPainter.height,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(FrameOverlayPainter oldDelegate) {
    return oldDelegate.preset != preset ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.maxHeight != maxHeight;
  }
}
