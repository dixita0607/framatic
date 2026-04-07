import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/camera/presentation/widgets/clipped_camera_preview.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_overlay.dart';

class CameraArea extends StatelessWidget {
  final CameraController controller;
  final Frame activeFrame;
  final Function(ScaleStartDetails) onScaleStart;
  final Function(ScaleUpdateDetails) onScaleUpdate;

  const CameraArea({
    super.key,
    required this.controller,
    required this.activeFrame,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final selectedAspectRatio = activeFrame.aspectRatio;

        return GestureDetector(
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          child: Stack(
            alignment: .center,
            children: [
              // Camera preview - clipped to selected aspect ratio
              Center(
                child: ClippedCameraPreview(
                  controller: controller,
                  targetAspectRatio: selectedAspectRatio,
                  maxHeight: maxHeight,
                ),
              ),

              // Frame overlay (aligned to top)
              Align(
                alignment: .topCenter,
                child: FrameOverlay(frame: activeFrame, maxHeight: maxHeight),
              ),
            ],
          ),
        );
      },
    );
  }
}
