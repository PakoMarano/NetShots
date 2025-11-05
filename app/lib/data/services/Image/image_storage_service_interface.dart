abstract class ImageStorageServiceInterface {
  Future<String> saveImage(String tempImagePath);   // Return the permanent path.
  Future<void> deleteImage(String imagePath);
  Future<bool> imageExists(String imagePath);
  Future<void> clearImages();
}