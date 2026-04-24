import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/utils/frame_calculator.dart';

/// Build camera preview that is clipped to the selected aspect ratio
class ClippedCameraPreview extends StatelessWidget {
  final CameraController controller;
  final double targetAspectRatio;

  const ClippedCameraPreview({
    super.key,
    required this.controller,
    required this.targetAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    // Camera preview size (note: width/height are swapped for portrait)
    final cameraWidth = controller.value.previewSize?.height ?? 1920;
    final cameraHeight = controller.value.previewSize?.width ?? 1080;
    final cameraAspectRatio = cameraWidth / cameraHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = fitToAspectRatio(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          aspectRatio: targetAspectRatio,
        );
        final frameWidth = previewSize.width;
        final frameHeight = previewSize.height;

        // Calculate camera preview size to minimize cropping
        // We want the camera to just cover the frame, not be overly zoomed
        double finalWidth, finalHeight;

        if (targetAspectRatio > cameraAspectRatio) {
          // Target is wider than camera - match width, crop height
          finalWidth = frameWidth;
          finalHeight = finalWidth / cameraAspectRatio;
        } else {
          // Target is taller than camera - match height, crop width
          finalHeight = frameHeight;
          finalWidth = finalHeight * cameraAspectRatio;
        }

        return ClipRect(
          child: SizedBox(
            width: frameWidth,
            height: frameHeight,
            child: OverflowBox(
              maxWidth: finalWidth,
              maxHeight: finalHeight,
              child: SizedBox(
                width: finalWidth,
                height: finalHeight,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}
