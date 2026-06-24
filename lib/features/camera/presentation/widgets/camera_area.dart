import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/utils/frame_calculator.dart';
import 'package:framatic/core/widgets/paper_frame.dart';
import 'package:framatic/features/camera/presentation/widgets/clipped_camera_preview.dart';

class CameraArea extends StatelessWidget {
  final CameraController controller;
  final Frame activeFrame;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final bool showGuides;

  const CameraArea({
    super.key,
    required this.controller,
    required this.activeFrame,
    required this.onScaleStart,
    required this.onScaleUpdate,
    this.showGuides = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final guideLineColor = theme.ink;
    final selectedAspectRatio = activeFrame.aspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = fitFramedAspectRatio(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          aspectRatio: selectedAspectRatio,
          longSideBorderRatio: AppConstants.frameBorderRatio,
          shortSideBorderCapRatio: AppConstants.maxFrameBorderShortSideRatio,
          bottomBorderMultiplier: AppConstants.frameBottomBorderMultiplier,
        );
        final borderWidth = previewSize.borderWidth;
        final bottomBorderWidth =
            borderWidth * AppConstants.frameBottomBorderMultiplier;

        return GestureDetector(
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          child: Center(
            child: PaperFrame(
              imageWidth: previewSize.width,
              imageHeight: previewSize.height,
              borderWidth: borderWidth,
              bottomBorderWidth: bottomBorderWidth,
              ratioLabel: activeFrame.paperRatio,
              child: Stack(
                alignment: .center,
                children: [
                  // Camera preview - clipped to selected aspect ratio
                  ClippedCameraPreview(
                    controller: controller,
                    targetAspectRatio: selectedAspectRatio,
                  ),
                  if (showGuides)
                    IgnorePointer(
                      child: SizedBox(
                        width: previewSize.width,
                        height: previewSize.height,
                        child: CustomPaint(
                          painter: _CompositionGuidePainter(
                            color: guideLineColor,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompositionGuidePainter extends CustomPainter {
  final Color color;

  const _CompositionGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = color.withValues(alpha: 0.52)
      ..strokeWidth = 1.1;
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.78)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final x in [size.width / 3, size.width * 2 / 3]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), guidePaint);
    }
    for (final y in [size.height / 3, size.height * 2 / 3]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guidePaint);
    }

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      center.translate(-10, 0),
      center.translate(10, 0),
      centerPaint,
    );
    canvas.drawLine(
      center.translate(0, -10),
      center.translate(0, 10),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(_CompositionGuidePainter oldDelegate) =>
      oldDelegate.color != color;
}
