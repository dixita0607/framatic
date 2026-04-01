import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/widgets/capture_button.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_overlay.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_selector.dart';
import 'package:framatic/features/camera/presentation/widgets/zoom_slider.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/frames_manager_screen.dart';
import 'package:framatic/features/photo_preview/data/photo_service.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_screen.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final PhotoService _photoService = PhotoService();
  double _baseZoom = 1.0; // For pinch gesture

  Future<void> _capturePhoto() async {
    final cameraProvider = context.read<CameraProvider>();
    final frameProvider = context.read<FrameProvider>();
    final preset = frameProvider.activeFrame;

    if (preset == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No frame selected')));
      }
      return;
    }

    try {
      final xFile = await cameraProvider.takePicture();
      if (xFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture photo')),
          );
        }
        return;
      }

      // Process with overlay
      final processedPath = await _photoService.processPhotoWithOverlay(
        imagePath: xFile.path,
        preset: preset,
      );

      if (processedPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process photo')),
          );
        }
        return;
      }

      // Navigate to preview screen
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoPreviewScreen(imagePath: processedPath),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  /// Build camera area with max height constraints
  Widget _buildCameraArea(CameraProvider cameraProvider) {
    final controller = cameraProvider.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;

        return Consumer<FrameProvider>(
          builder: (context, frameProvider, child) {
            final activeFrame = frameProvider.activeFrame;

            // Show loading state if no active frame yet
            if (activeFrame == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final selectedAspectRatio = activeFrame.aspectRatio;

            return GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera preview - clipped to selected aspect ratio
                  Center(
                    child: _buildClippedCameraPreview(
                      controller,
                      selectedAspectRatio,
                      maxHeight,
                    ),
                  ),

                  // Frame overlay (aligned to top)
                  Align(
                    alignment: Alignment.topCenter,
                    child: FrameOverlay(
                      preset: activeFrame,
                      maxHeight: maxHeight,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Build simplified bottom controls (no arrows)
  Widget _buildSimplifiedBottomControls(CameraProvider cameraProvider) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Zoom slider
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ZoomSlider(
              minZoom: cameraProvider.minZoom,
              maxZoom: cameraProvider.maxZoom,
              currentZoom: cameraProvider.currentZoom,
              onZoomChanged: _onZoomChanged,
            ),
          ),

          // Control buttons row (settings, capture, flip camera)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Settings button (left)
              IconButton(
                icon: const Icon(Icons.settings, size: 28),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FramesManagerScreen(),
                    ),
                  );
                },
                tooltip: 'Manage Presets',
              ),

              // Capture button (center)
              CaptureButton(
                isCapturing: cameraProvider.isCapturing,
                onPressed: _capturePhoto,
              ),

              // Flip camera button (right)
              IconButton(
                onPressed: () => cameraProvider.switchCamera(),
                icon: const Icon(Icons.flip_camera_ios, size: 28),
                color: Colors.white,
              ),
            ],
          ),

          // Gap between control buttons and frame selector
          const SizedBox(height: 32),

          // Frame selector (48px)
          const SizedBox(height: 48, child: FrameSelector()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: cameraProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : cameraProvider.errorMessage != null
            ? _buildErrorWidget(cameraProvider)
            : Column(
                children: [
                  Expanded(child: _buildCameraArea(cameraProvider)),
                  _buildSimplifiedBottomControls(cameraProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorWidget(CameraProvider cameraProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              cameraProvider.errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => cameraProvider.retry(),
              child: const Text('Retry'),
            ),
            if (cameraProvider.errorMessage?.contains('permission') ?? false)
              TextButton(
                onPressed: () => PermissionService.openSettings(),
                child: const Text('Open Settings'),
              ),
          ],
        ),
      ),
    );
  }

  /// Build camera preview that is clipped to the selected aspect ratio
  /// Uses same frame calculation as FrameOverlay to ensure alignment
  Widget _buildClippedCameraPreview(
    CameraController controller,
    double targetAspectRatio,
    double maxHeight,
  ) {
    // Camera preview size (note: width/height are swapped for portrait)
    final previewWidth = controller.value.previewSize?.height ?? 1920;
    final previewHeight = controller.value.previewSize?.width ?? 1080;
    final cameraAspectRatio = previewWidth / previewHeight;
    const borderWidth = AppConstants.frameBorderThickness;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate frame size exactly like FrameOverlay does
        // Account for border width so camera stays within the border
        final availableWidth =
            constraints.maxWidth * AppConstants.maxFramePadding -
            (borderWidth * 2);
        final availableHeight =
            constraints.maxHeight * AppConstants.maxFramePadding -
            (borderWidth * 2);

        double frameWidth = availableWidth;
        double frameHeight = frameWidth / targetAspectRatio;

        if (frameHeight > availableHeight) {
          frameHeight = availableHeight;
          frameWidth = frameHeight * targetAspectRatio;
        }

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
