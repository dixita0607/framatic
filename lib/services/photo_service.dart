import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/utils/constants.dart';

/// Service for photo capture processing and gallery export
class PhotoService {
  static const String albumName = 'Artist Frames';
  static const int borderWidth = AppConstants.frameBorderWidthInt;

  /// Process captured photo: crop to aspect ratio and add polaroid border
  /// Returns the processed image bytes
  Future<Uint8List?> processPhotoWithOverlay({
    required String imagePath,
    required FramePreset preset,
  }) async {
    try {
      // Read the captured image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Calculate crop dimensions based on aspect ratio
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;
      final imageAspectRatio = imageWidth / imageHeight;

      int cropWidth, cropHeight, cropLeft, cropTop;

      if (preset.aspectRatio > imageAspectRatio) {
        // Frame is wider than image - fit to width, crop height
        cropWidth = imageWidth;
        cropHeight = (imageWidth / preset.aspectRatio).round();
      } else {
        // Frame is taller than image - fit to height, crop width
        cropHeight = imageHeight;
        cropWidth = (imageHeight * preset.aspectRatio).round();
      }

      // Center the crop
      cropLeft = ((imageWidth - cropWidth) / 2).round();
      cropTop = ((imageHeight - cropHeight) / 2).round();

      // Crop the image to the frame aspect ratio
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropLeft,
        y: cropTop,
        width: cropWidth,
        height: cropHeight,
      );

      // Create final image with border
      final finalWidth = cropWidth + (borderWidth * 2);
      final finalHeight = cropHeight + (borderWidth * 2);

      final finalImage = img.Image(
        width: finalWidth,
        height: finalHeight,
      );

      // Fill with white (border color)
      final borderColor = img.ColorRgba8(255, 255, 255, 255);
      img.fill(finalImage, color: borderColor);

      // Composite the cropped image onto the center
      img.compositeImage(
        finalImage,
        croppedImage,
        dstX: borderWidth,
        dstY: borderWidth,
      );

      // Encode as JPEG
      final processedBytes = Uint8List.fromList(
        img.encodeJpg(finalImage, quality: 95),
      );

      return processedBytes;
    } catch (e) {
      debugPrint('Error processing photo with overlay: $e');
      return null;
    }
  }

  /// Save processed photo to gallery
  Future<bool> saveToGallery(Uint8List imageBytes) async {
    try {
      // Save to temporary file first
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await tempFile.writeAsBytes(imageBytes);

      // Save to gallery with album name
      await Gal.putImage(tempFile.path, album: albumName);

      // Clean up temp file
      await tempFile.delete();

      return true;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  /// Request storage permission for saving photos
  Future<bool> requestStoragePermission() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        return await Gal.requestAccess();
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }
}
