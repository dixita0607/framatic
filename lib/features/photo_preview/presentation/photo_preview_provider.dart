import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';

class PhotoPreviewProvider extends ChangeNotifier {
  final PhotoRepository _photoRepository;

  bool _isSaving = false;

  PhotoPreviewProvider(this._photoRepository);

  bool get isSaving => _isSaving;

  /// Process a photo with the given frame overlay
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) {
    return _photoRepository.processPhotoWithFrame(
      imagePath: imagePath,
      frame: frame,
    );
  }

  Future<void> savePhoto(String imagePath) async {
    _isSaving = true;
    notifyListeners();

    try {
      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) {
        throw PermissionError(
          'Storage permission denied',
          userMessage: 'Storage permission is required to save photos.',
        );
      }

      await _photoRepository.saveToGallery(imagePath);
    } on AppError {
      rethrow;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void retakePhoto(String imagePath) {
    File(imagePath).delete().ignore();
  }

  String get successMessage =>
      'Photo saved to ${AppConstants.galleryAlbumName} album';
}
