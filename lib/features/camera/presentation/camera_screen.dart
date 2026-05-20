import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
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

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _baseZoom = 1.0; // For pinch gesture

  Future<void> _capturePhoto() async {
    final cameraProvider = context.read<CameraProvider>();
    final frameProvider = context.read<FrameProvider>();
    final photoProvider = context.read<PhotoPreviewProvider>();
    final activeFrame = frameProvider.activeFrame;

    if (activeFrame == null) {
      if (mounted) {
        SketchToast.show(context, 'No frame selected', isError: true);
      }
      return;
    }

    try {
      final xFile = await cameraProvider.takePicture();
      if (xFile == null) {
        if (mounted) {
          SketchToast.show(context, 'Failed to capture photo', isError: true);
        }
        return;
      }

      // Process with overlay
      final processedPath = await photoProvider.processPhotoWithFrame(
        imagePath: xFile.path,
        frame: activeFrame,
      );

      // Navigate to preview screen
      if (mounted) {
        await Navigator.of(context).push(
          sketchPageRoute(
            (context) => PhotoPreviewScreen(imagePath: processedPath),
          ),
        );
      }
    } on AppError catch (e) {
      if (mounted) {
        context.showErrorToast(e);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast(
          UnexpectedError('Unexpected error during capture: $e', cause: e),
        );
      }
    }
  }

  /// Handle zoom slider change
  Future<void> _onZoomChanged(double zoom) async {
    await context.read<CameraProvider>().setZoomLevel(zoom);
  }

  /// Handle pinch gesture start
  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = context.read<CameraProvider>().currentZoom;
  }

  /// Handle pinch gesture update
  Future<void> _onScaleUpdate(ScaleUpdateDetails details) async {
    final cameraProvider = context.read<CameraProvider>();

    // Calculate new zoom based on pinch scale
    final newZoom = (_baseZoom * details.scale).clamp(
      cameraProvider.minZoom,
      cameraProvider.maxZoom,
    );

    if ((newZoom - cameraProvider.currentZoom).abs() > 0.01) {
      await cameraProvider.setZoomLevel(newZoom);
    }
  }

  void _onManageFrames() => Navigator.of(
    context,
  ).push(sketchPageRoute((context) => const FramesManagerScreen()));

  @override
  Widget build(BuildContext context) {
    return SketchScreen(
      child: Consumer2<CameraProvider, FrameProvider>(
        builder: (context, cameraProvider, frameProvider, child) {
          // Show loading when initializing or controller is null
          if (cameraProvider.isLoading || cameraProvider.controller == null) {
            return const Center(child: SketchProgress(size: 42));
          }

          // Show error if present
          if (cameraProvider.error != null) {
            return CameraErrorWidget(
              error: cameraProvider.error,
              onRetry: cameraProvider.retry,
            );
          }

          // Show camera view
          return Column(
            children: [
              Expanded(
                child: CameraArea(
                  controller: cameraProvider.controller!,
                  activeFrame: frameProvider.activeFrame!,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 64),
                child: Column(
                  mainAxisAlignment: .start,
                  children: [
                    // Zoom slider
                    Padding(
                      padding: const .only(bottom: 16),
                      child: ZoomSlider(
                        minZoom: cameraProvider.minZoom,
                        maxZoom: cameraProvider.maxZoom,
                        currentZoom: cameraProvider.currentZoom,
                        onZoomChanged: _onZoomChanged,
                      ),
                    ),

                    // Control buttons row (settings, capture, flip camera)
                    Row(
                      mainAxisAlignment: .spaceEvenly,
                      crossAxisAlignment: .center,
                      children: [
                        SketchIconButton(
                          icon: SketchIconType.settings,
                          onPressed: _onManageFrames,
                          tooltip: 'Manage Frames',
                        ),

                        CaptureButton(
                          isCapturing: cameraProvider.isCapturing,
                          onPressed: _capturePhoto,
                        ),

                        SketchIconButton(
                          onPressed: () => cameraProvider.switchCamera(),
                          icon: SketchIconType.flipCamera,
                          tooltip: 'Switch Camera',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
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
    );
  }
}
