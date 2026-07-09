import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/camera/domain/camera_constants.dart';
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

typedef CameraViewportBuilder =
    Widget Function(BuildContext context, Frame activeFrame);

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.cameraViewportBuilder});

  // Integration tests can provide a fake viewport here so the camera controls
  // render without needing a platform-backed CameraController. Production leaves
  // this null and uses the real CameraArea below.
  final CameraViewportBuilder? cameraViewportBuilder;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _baseZoom = defaultZoomLevel; // For pinch gesture
  bool _isPreparingPreview = false;
  bool _showGuides = true;

  Future<void> _capturePhoto() async {
    if (_isPreparingPreview) return;

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

      if (mounted) {
        setState(() => _isPreparingPreview = true);
      }

      final processedPath = await photoProvider.processPhotoWithFrame(
        imagePath: xFile.path,
        frame: activeFrame,
      );

      // Navigate to preview screen
      if (mounted) {
        final didSave = await Navigator.of(context).push<bool>(
          sketchPageRoute(
            (context) => PhotoPreviewScreen(imagePath: processedPath),
          ),
        );
        if (didSave == true && mounted) {
          SketchToast.show(context, photoProvider.successMessage);
        }
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
    } finally {
      if (mounted) {
        setState(() => _isPreparingPreview = false);
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
          // Show error if present
          if (cameraProvider.error != null) {
            return CameraErrorWidget(
              error: cameraProvider.error,
              onRetry: cameraProvider.retry,
            );
          }

          // A real camera screen cannot render without a CameraController, but
          // tests may supply cameraViewportBuilder to exercise the surrounding UI.
          if (cameraProvider.isLoading ||
              (cameraProvider.controller == null &&
                  widget.cameraViewportBuilder == null)) {
            return const Center(child: SketchProgress(size: 42));
          }

          if (frameProvider.isLoading) {
            return const _FrameStateMessage(
              title: 'Loading frames',
              message: 'Preparing your frame choices.',
              isLoading: true,
            );
          }

          final activeFrame = frameProvider.activeFrame;
          if (activeFrame == null) {
            return _FrameStateMessage(
              title: 'No frames available',
              message:
                  'Add a custom frame or restart the app to restore the built-in ratios.',
              primaryLabel: 'Manage Frames',
              onPrimary: _onManageFrames,
            );
          }

          // Show camera view
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    widget.cameraViewportBuilder?.call(context, activeFrame) ??
                        CameraArea(
                          controller: cameraProvider.controller!,
                          activeFrame: activeFrame,
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          showGuides: _showGuides,
                        ),
                    Positioned(
                      right: 18,
                      top: 18,
                      child: _GridToggle(
                        isEnabled: _showGuides,
                        onPressed: () {
                          setState(() => _showGuides = !_showGuides);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          key: const ValueKey('frame_manager_button'),
                          icon: SketchIconType.settings,
                          onPressed: _onManageFrames,
                          tooltip: 'Manage Frames',
                        ),

                        CaptureButton(
                          key: const ValueKey('capture_button'),
                          isCapturing:
                              cameraProvider.isCapturing || _isPreparingPreview,
                          onPressed: _isPreparingPreview ? null : _capturePhoto,
                        ),

                        SketchIconButton(
                          onPressed: () => cameraProvider.switchCamera(),
                          icon: SketchIconType.flipCamera,
                          tooltip: 'Switch Camera',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 44,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPreparingPreview ? 1 : 0,
                          duration: const Duration(milliseconds: 120),
                          child: Text(
                            'Preparing preview',
                            style: SketchTheme.of(
                              context,
                            ).label.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: FrameSelector(
                        key: const ValueKey('frame_selector'),
                        frames: frameProvider.frames,
                        activeFrame: activeFrame,
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

class _GridToggle extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _GridToggle({required this.isEnabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Semantics(
      button: true,
      toggled: isEnabled,
      label: isEnabled ? 'Hide grid' : 'Show grid',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: SketchSurface(
              shape: SketchShape.rect,
              fillColor: theme.panel,
              strokeColor: theme.ink,
              hachure: isEnabled,
              hachureColor: theme.ink.withValues(alpha: 0.18),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              seed: 731,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SketchIcon(
                    type: SketchIconType.grid,
                    size: 18,
                    color: theme.ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Grid',
                    style: theme.label.copyWith(
                      color: theme.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrameStateMessage extends StatelessWidget {
  final String title;
  final String message;
  final bool isLoading;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  const _FrameStateMessage({
    required this.title,
    required this.message,
    this.isLoading = false,
    this.primaryLabel,
    this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SketchSurface(
          fillColor: theme.panelStrong,
          hachure: true,
          padding: const EdgeInsets.all(20),
          seed: title.hashCode,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                const SketchProgress(size: 36),
                const SizedBox(height: 16),
              ],
              Text(title, style: theme.title, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: theme.bodyText, textAlign: TextAlign.center),
              if (primaryLabel != null) ...[
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SketchButton(label: primaryLabel!, onPressed: onPrimary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
