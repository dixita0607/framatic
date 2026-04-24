import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/utils/frame_calculator.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PhotoService implements PhotoRepository {
  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    try {
      // Read bytes on the main isolate (async I/O, non-blocking)
      final imageBytes = await File(imagePath).readAsBytes();

      // All CPU-bound work runs in a background isolate so the UI stays free.
      // The closure captures only sendable values (Uint8List, double, int).
      final resultBytes = await Isolate.run(
        () => _processImage(imageBytes, frame.aspectRatio),
      );

      // Write result back to a temp file on the main isolate (async I/O)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await imageFile.writeAsBytes(resultBytes);

      return imageFile.path;
    } catch (e) {
      throw ProcessPhotoError(
        'Error processing photo with overlay: $e',
        userMessage: 'Failed to process photo.',
        cause: e,
      );
    }
  }

  /// Save processed photo to gallery and delete the temp file.
  @override
  Future<void> saveToGallery(String imagePath) async {
    try {
      await Gal.putImage(imagePath, album: AppConstants.appName);
      await File(imagePath).delete();
    } on GalException catch (e) {
      throw SavePhotoError(
        'Error saving to gallery: ${e.type.message}',
        userMessage: 'Failed to save photo to gallery.',
        cause: e,
      );
    }
  }

  static Future<void> cleanupTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.startsWith('frame_'))
        .forEach((f) => f.delete().ignore());
  }

  /// Runs entirely inside the background isolate.
  /// Must be a static method — instance methods cannot be sent across isolates.
  static Uint8List _processImage(Uint8List imageBytes, double aspectRatio) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw DecodePhotoError(
        'Failed to decode image',
        userMessage: 'Failed to process photo.',
      );
    }

    final innerImageSize = fitToAspectRatio(
      maxWidth: originalImage.width.toDouble(),
      maxHeight: originalImage.height.toDouble(),
      aspectRatio: aspectRatio,
    );
    final cropWidth = innerImageSize.width.round();
    final cropHeight = innerImageSize.height.round();
    final cropLeft = ((originalImage.width - cropWidth) / 2).round();
    final cropTop = ((originalImage.height - cropHeight) / 2).round();

    final croppedImage = img.copyCrop(
      originalImage,
      x: cropLeft,
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );

    // This 4 as a multiplier works as an illusion here. It looks like the border is as thick as in camera preview screen.
    // TODO: Revisit the calculations of border thickness if device specific issues are observed in future.

    final imageWithBorder = img.Image(
      width: croppedImage.width + (4 * AppConstants.frameBorder),
      height: croppedImage.height + (4 * AppConstants.frameBorder),
    );

    img.fill(imageWithBorder, color: img.ColorRgba8(255, 255, 255, 255));

    img.compositeImage(imageWithBorder, croppedImage, center: true);

    return Uint8List.fromList(img.encodeJpg(imageWithBorder));
  }
}
