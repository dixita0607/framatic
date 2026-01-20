import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/services/camera_service.dart';
import 'package:framatic/utils/permissions.dart';
import 'package:framatic/widgets/frame_overlay.dart';
import 'package:framatic/widgets/frame_selector.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isLoading = true;
  String? _errorMessage;

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

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
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
                : _buildCameraPreview(),
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

  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<FrameProvider>(
      builder: (context, frameProvider, child) {
        final selectedAspectRatio = frameProvider.activePreset.aspectRatio;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview - clipped to selected aspect ratio
            Center(
              child: _buildClippedCameraPreview(controller, selectedAspectRatio),
            ),

            // Frame overlay (just the white border area outside the frame)
            FrameOverlay(
              preset: frameProvider.activePreset,
            ),

            // Controls overlay
            _buildControls(),
          ],
        );
      },
    );
  }

  /// Build camera preview that is clipped to the selected aspect ratio
  Widget _buildClippedCameraPreview(
    CameraController controller,
    double targetAspectRatio,
  ) {
    // Camera preview size (note: width/height are swapped for portrait)
    final previewWidth = controller.value.previewSize?.height ?? 1920;
    final previewHeight = controller.value.previewSize?.width ?? 1080;
    final cameraAspectRatio = previewWidth / previewHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size for the target aspect ratio that fits within screen
        final maxWidth = constraints.maxWidth * 0.95;
        final maxHeight = constraints.maxHeight * 0.95;

        double frameWidth = maxWidth;
        double frameHeight = frameWidth / targetAspectRatio;

        if (frameHeight > maxHeight) {
          frameHeight = maxHeight;
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

  Widget _buildControls() {
    return Column(
      children: [
        // Top bar
        _buildTopBar(),

        const Spacer(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name/title
          const Text(
            'Framatic',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
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

          // Settings icon placeholder
          IconButton(
            onPressed: () {
              // TODO: Open settings
            },
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Consumer<FrameProvider>(
      builder: (context, frameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Frame selector
              const FrameSelector(),

              const SizedBox(height: 16),

              // Main action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous frame
                  IconButton(
                    onPressed: frameProvider.previousPreset,
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    iconSize: 32,
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement photo capture
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Next frame
                  IconButton(
                    onPressed: frameProvider.nextPreset,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                    iconSize: 32,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
