import 'package:netshots/data/services/image_storage/image_storage_service_interface.dart';

class ImageStorageRepository {
  final ImageStorageServiceInterface _service;

  ImageStorageRepository(this._service);

  Future<String> saveImage(String tempImagePath) {
    return _service.saveImage(tempImagePath);
  }

  Future<void> deleteImage(String imagePath) {
    return _service.deleteImage(imagePath);
  }

  Future<bool> imageExists(String imagePath) {
    return _service.imageExists(imagePath);
  }

  Future<void> clearImages() {
    return _service.clearImages();
  }
}
