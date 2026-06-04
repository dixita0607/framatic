import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:framatic/core/widgets/app_icons.dart';
import 'package:framatic/core/widgets/dotted_background.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/widgets/camera_area.dart';
import 'package:framatic/features/camera/presentation/widgets/camera_error_widget.dart';
import 'package:framatic/features/camera/presentation/widgets/capture_button.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_selector.dart';
import 'package:framatic/features/camera/presentation/widgets/zoom_slider.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/frames_manager_screen.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _baseZoom = 1.0;

  Future<void> _capturePhoto() async {
    final cameraProvider = context.read<CameraProvider>();
    final frameProvider = context.read<FrameProvider>();
    final photoProvider = context.read<PhotoPreviewProvider>();
    final activeFrame = frameProvider.activeFrame;

    if (activeFrame == null) {
      if (mounted) {
        SketchySnackBar.show(context, message: 'No frame selected');
      }
      return;
    }

    try {
      final xFile = await cameraProvider.takePicture();
      if (xFile == null) {
        if (mounted) {
          SketchySnackBar.show(context, message: 'Failed to capture photo');
        }
        return;
      }

      final String processedPath;
      try {
        processedPath = await photoProvider.processPhotoWithFrame(
          imagePath: xFile.path,
          frame: activeFrame,
        );
      } catch (_) {
        try { await File(xFile.path).delete(); } catch (_) {}
        rethrow;
      }

      if (mounted) {
        await Navigator.of(context).push(
          SketchyPageRoute(
            builder: (context) => PhotoPreviewScreen(imagePath: processedPath),
          ),
        );
      }
    } on AppError catch (e) {
      if (mounted) context.showErrorSnackBar(e);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          UnexpectedError('Unexpected error during capture: $e', cause: e),
        );
      }
    }
  }

  Future<void> _onZoomChanged(double zoom) async {
    await context.read<CameraProvider>().setZoomLevel(zoom);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = context.read<CameraProvider>().currentZoom;
  }

  Future<void> _onScaleUpdate(ScaleUpdateDetails details) async {
    final cameraProvider = context.read<CameraProvider>();
    final newZoom = (_baseZoom * details.scale).clamp(
      cameraProvider.minZoom,
      cameraProvider.maxZoom,
    );
    if ((newZoom - cameraProvider.currentZoom).abs() > 0.01) {
      await cameraProvider.setZoomLevel(newZoom);
    }
  }

  void _onManageFrames() => Navigator.of(context).push(
        SketchyPageRoute(builder: (context) => const FramesManagerScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final ink = SketchyTheme.of(context).inkColor;

    return DottedScaffold(
      body: SafeArea(
        child: Consumer2<CameraProvider, FrameProvider>(
          builder: (context, cameraProvider, frameProvider, child) {
            if (cameraProvider.isLoading ||
                cameraProvider.controller == null ||
                frameProvider.isLoading) {
              return const Center(child: SketchyCircularProgressIndicator());
            }

            if (cameraProvider.error != null) {
              return CameraErrorWidget(
                error: cameraProvider.error,
                onRetry: cameraProvider.retry,
              );
            }

            if (frameProvider.activeFrame == null) {
              return CameraErrorWidget(
                error: frameProvider.initError,
                onRetry: frameProvider.retry,
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraArea(
                        controller: cameraProvider.controller!,
                        activeFrame: frameProvider.activeFrame!,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SketchyFrame(
                            fill: SketchyFill.solid,
                            fillColor: ink.withValues(alpha: 0.55),
                            cornerRadius: 12,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              child: Text(
                                frameProvider.activeFrame!.title,
                                style: TextStyle(
                                  color: SketchyTheme.of(context).paperColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 0, 16,
                        16 + MediaQuery.of(context).viewPadding.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ZoomSlider(
                            minZoom: cameraProvider.minZoom,
                            maxZoom: cameraProvider.maxZoom,
                            currentZoom: cameraProvider.currentZoom,
                            onZoomChanged: _onZoomChanged,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SketchyIconButton(
                              icon: SketchySymbol(symbol: SketchySymbols.gear, color: ink),
                              onPressed: _onManageFrames,
                              iconSize: 40,
                            ),
                            CaptureButton(
                              isCapturing: cameraProvider.isCapturing,
                              onPressed: _capturePhoto,
                            ),
                            SketchyIconButton(
                              icon: RotateCameraIcon(color: ink),
                              onPressed: () => cameraProvider.switchCamera(),
                              iconSize: 40,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 50,
                          child: FrameSelector(
                            frames: frameProvider.frames,
                            activeFrame: frameProvider.activeFrame!,
                            isLoading: frameProvider.isLoading,
                            onFrameSelected: frameProvider.setActiveFrame,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
