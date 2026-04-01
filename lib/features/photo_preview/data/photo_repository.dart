import 'package:framatic/core/models/frame.dart';

abstract interface class PhotoRepository {
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  });

  Future<bool> saveToGallery(String imagePath);
}
