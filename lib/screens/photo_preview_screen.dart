import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:framatic/services/photo_service.dart';

/// Screen to preview captured photo with Save/Retake options
class PhotoPreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const PhotoPreviewScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final PhotoService _photoService = PhotoService();
  bool _isSaving = false;

  Future<void> _savePhoto() async {
    setState(() {
      _isSaving = true;
    });

    final hasPermission = await _photoService.requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission required to save photos'),
          ),
        );
      }
      return;
    }

    final success = await _photoService.saveToGallery(widget.imageBytes);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo saved to Artist Frames album'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate save success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save photo'),
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    Navigator.of(context).pop(false); // Return false to indicate retake
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Preview image
            Expanded(
              child: Center(
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  _buildActionButton(
                    icon: Icons.close,
                    label: 'Retake',
                    onPressed: _isSaving ? null : _retakePhoto,
                  ),

                  // Save button
                  _buildActionButton(
                    icon: Icons.check,
                    label: 'Save',
                    onPressed: _isSaving ? null : _savePhoto,
                    isPrimary: true,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isLoading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? Colors.white : Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Icon(
                    icon,
                    color: isPrimary ? Colors.black : Colors.white,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
