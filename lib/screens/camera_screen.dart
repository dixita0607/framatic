import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/services/camera_service.dart';
import 'package:framatic/services/photo_service.dart';
import 'package:framatic/screens/photo_preview_screen.dart';
import 'package:framatic/screens/preset_manager_screen.dart';
import 'package:framatic/utils/constants.dart';
import 'package:framatic/utils/permissions.dart';
import 'package:framatic/widgets/frame_overlay.dart';
import 'package:framatic/widgets/frame_selector.dart';
import 'package:framatic/widgets/zoom_slider.dart';
import 'package:framatic/widgets/camera_controls/capture_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final PhotoService _photoService = PhotoService();
  bool _isLoading = true;
  bool _isCapturing = false;
  String? _errorMessage;

  // Zoom state
  double _currentZoom = 1.0;
  double _baseZoom = 1.0; // For pinch gesture

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check and request camera permission
      final hasPermission = await PermissionsHelper.checkCameraPermission();
      if (!hasPermission) {
        final granted = await PermissionsHelper.requestCameraPermission();
        if (!granted) {
          setState(() {
            _errorMessage = 'Camera permission is required';
            _isLoading = false;
          });
          return;
        }
      }

      // Initialize camera
      await _cameraService.initializeCameras();
      await _cameraService.initializeController();

      // Set initial zoom to minimum (widest view)
      setState(() {
        _currentZoom = _cameraService.currentZoom;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }


  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    final frameProvider = context.read<FrameProvider>();
    final preset = frameProvider.activePreset;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Take the picture
      final xFile = await _cameraService.takePicture();
      if (xFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture photo')),
          );
        }
        return;
      }

      // Process with overlay
      final processedBytes = await _photoService.processPhotoWithOverlay(
        imagePath: xFile.path,
        preset: preset,
      );

      if (processedBytes == null) {
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
            builder: (context) => PhotoPreviewScreen(
              imageBytes: processedBytes,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// Handle zoom slider change
  Future<void> _onZoomChanged(double zoom) async {
    await _cameraService.setZoomLevel(zoom);
    setState(() {
      _currentZoom = zoom;
    });
  }

  /// Handle pinch gesture start
  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  /// Handle pinch gesture update
  Future<void> _onScaleUpdate(ScaleUpdateDetails details) async {
    // Calculate new zoom based on pinch scale
    final newZoom = (_baseZoom * details.scale).clamp(
      _cameraService.minZoom,
      _cameraService.maxZoom,
    );

    if ((newZoom - _currentZoom).abs() > 0.01) {
      await _cameraService.setZoomLevel(newZoom);
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  /// Switch between front and back cameras
  Future<void> _flipCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _cameraService.switchCamera();
      // Update zoom state after camera switch (new camera may have different zoom range)
      setState(() {
        _currentZoom = _cameraService.currentZoom;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to switch camera: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  /// Build camera area with max height constraints
  Widget _buildCameraArea() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;

        return Consumer<FrameProvider>(
          builder: (context, frameProvider, child) {
            final selectedAspectRatio = frameProvider.activePreset.aspectRatio;

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
                      preset: frameProvider.activePreset,
                      maxHeight: maxHeight,
                    ),
                  ),

                  // Zoom slider on the right side
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: ZoomSlider(
                        minZoom: _cameraService.minZoom,
                        maxZoom: _cameraService.maxZoom,
                        currentZoom: _currentZoom,
                        onZoomChanged: _onZoomChanged,
                      ),
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
  Widget _buildSimplifiedBottomControls() {
    return Container(
      height: 200,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Frame selector (48px)
          const SizedBox(
            height: 48,
            child: FrameSelector(),
          ),

          // Gap between frame selector and control buttons
          const SizedBox(height: 32),

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
                      builder: (context) => const PresetManagerScreen(),
                    ),
                  );
                },
                tooltip: 'Manage Presets',
              ),

              // Capture button (center)
              CaptureButton(
                isCapturing: _isCapturing,
                onPressed: _capturePhoto,
              ),

              // Flip camera button (right)
              IconButton(
                onPressed: _flipCamera,
                icon: const Icon(Icons.flip_camera_ios, size: 28),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorWidget()
                : Column(
                    children: [
                      Expanded(child: _buildCameraArea()),
                      _buildSimplifiedBottomControls(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
            if (_errorMessage?.contains('permission') ?? false)
              TextButton(
                onPressed: () => PermissionsHelper.openAppSettings(),
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
    const borderWidth = AppConstants.frameBorderWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate frame size exactly like FrameOverlay does
        // Account for border width so camera stays within the border
        final availableWidth =
            constraints.maxWidth * AppConstants.maxFramePadding - (borderWidth * 2);
        final availableHeight =
            constraints.maxHeight * AppConstants.maxFramePadding - (borderWidth * 2);

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
