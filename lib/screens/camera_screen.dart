import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/services/camera_service.dart';
import 'package:framatic/utils/constants.dart';
import 'package:framatic/utils/permissions.dart';
import 'package:framatic/widgets/frame_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPresetIndex = 1; // Default to 16:9
  final List<FramePreset> _presets = AspectRatios.predefinedFrames;

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

  void _switchFrame() {
    setState(() {
      _currentPresetIndex = (_currentPresetIndex + 1) % _presets.length;
    });
  }

  void _previousFrame() {
    setState(() {
      _currentPresetIndex =
          (_currentPresetIndex - 1 + _presets.length) % _presets.length;
    });
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

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),

        // Frame overlay
        FrameOverlay(
          preset: _presets[_currentPresetIndex],
        ),

        // Controls overlay
        _buildControls(),
      ],
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
            AppConstants.appName,
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Frame selector chips
          _buildFrameSelector(),

          const SizedBox(height: 16),

          // Main action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous frame
              IconButton(
                onPressed: _previousFrame,
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
                onPressed: _switchFrame,
                icon: const Icon(Icons.arrow_forward_ios),
                color: Colors.white,
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrameSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _presets.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentPresetIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_presets[index].name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentPresetIndex = index;
                  });
                }
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
