import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/services/camera_service.dart';
import 'package:framatic/services/photo_service.dart';
import 'package:framatic/screens/photo_preview_screen.dart';
import 'package:framatic/utils/constants.dart';
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
  final PhotoService _photoService = PhotoService();
  bool _isLoading = true;
  bool _isCapturing = false;
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
  /// Uses same frame calculation as FrameOverlay to ensure alignment
  Widget _buildClippedCameraPreview(
    CameraController controller,
    double targetAspectRatio,
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
                    onTap: _isCapturing ? null : _capturePhoto,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : Container(
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
