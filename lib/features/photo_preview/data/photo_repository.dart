import 'package:framatic/core/models/frame.dart';

abstract interface class PhotoRepository {
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  });

  Future<void> saveToGallery(String imagePath);
}
