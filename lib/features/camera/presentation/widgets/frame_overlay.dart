import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/constants.dart';

/// Widget that displays a polaroid-style frame border over the camera preview
class FrameOverlay extends StatelessWidget {
  final Frame frame;
  final double? maxHeight;

  const FrameOverlay({
    super.key,
    required this.frame,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = _calculateFrameSize(
          constraints.maxWidth,
          maxHeight ?? constraints.maxHeight,
        );
        final borderWidth = (frameSize.width * AppConstants.frameBorderPercentage).round();
        final totalWidth = frameSize.width + (borderWidth * 2).toDouble();
        final totalHeight = frameSize.height + (borderWidth * 2).toDouble();

        // Calculate centered position
        final left = (constraints.maxWidth - totalWidth) / 2;
        final top = ((maxHeight ?? constraints.maxHeight) - totalHeight) / 2;

        return Stack(
          children: [
            // Frame border using Container with border decoration
            Positioned(
              left: left,
              top: top,
              width: totalWidth,
              height: totalHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: borderWidth.toDouble(),
                  ),
                ),
              ),
            ),
            // Frame title label - positioned above frame
            Positioned(
              left: 0,
              right: 0,
              top: top - borderWidth - 8,
              child: Center(
                child: Text(
                  frame.title,
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Calculate frame size that fits within the screen while maintaining aspect ratio
  /// Accounts for border width (percentage-based) so the border doesn't get clipped
  Size _calculateFrameSize(double maxWidth, double maxHeight) {
    final borderFactor = 1 + (2 * AppConstants.frameBorderPercentage);
    final availableWidth = maxWidth * AppConstants.maxFramePadding / borderFactor;
    final availableHeight = maxHeight * AppConstants.maxFramePadding / borderFactor;

    double frameWidth = availableWidth;
    double frameHeight = frameWidth / frame.aspectRatio;

    // If height exceeds available bounds, scale based on height instead
    if (frameHeight > availableHeight) {
      frameHeight = availableHeight;
      frameWidth = frameHeight * frame.aspectRatio;
    }

    return Size(frameWidth, frameHeight);
  }
}
