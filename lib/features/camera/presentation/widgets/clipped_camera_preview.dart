import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/utils/frame_calculator.dart';

/// Build camera preview that is clipped to the selected aspect ratio
/// Uses same frame calculation as FrameOverlay to ensure alignment
class ClippedCameraPreview extends StatelessWidget {
  final CameraController controller;
  final double targetAspectRatio;
  final double maxHeight;

  const ClippedCameraPreview({
    super.key,
    required this.controller,
    required this.targetAspectRatio,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Camera preview size (note: width/height are swapped for portrait)
    final previewWidth = controller.value.previewSize?.height ?? 1920;
    final previewHeight = controller.value.previewSize?.width ?? 1080;
    final cameraAspectRatio = previewWidth / previewHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = calculateFrameSize(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          aspectRatio: targetAspectRatio,
        );
        final frameWidth = frameSize.width;
        final frameHeight = frameSize.height;

        // Calculate camera preview size to minimize cropping
        // We want the camera to just cover the frame, not be overly zoomed
        double cameraWidth, cameraHeight;

        if (targetAspectRatio > cameraAspectRatio) {
          // Target is wider than camera - match width, crop height
          cameraWidth = frameWidth;
          cameraHeight = cameraWidth / cameraAspectRatio;
        } else {
          // Target is taller than camera - match height, crop width
          cameraHeight = frameHeight;
          cameraWidth = cameraHeight * cameraAspectRatio;
        }

        return ClipRect(
          child: SizedBox(
            width: frameWidth,
            height: frameHeight,
            child: OverflowBox(
              maxWidth: cameraWidth,
              maxHeight: cameraHeight,
              child: SizedBox(
                width: cameraWidth,
                height: cameraHeight,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}
