import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:netshots/data/services/image_storage/image_storage_service_interface.dart';

class ImageStorageServiceMock implements ImageStorageServiceInterface {
  static const String _profileImagesFolder = 'profile_images';

  /// Copy a temporary image to a permanent location
  @override
  Future<String> saveImage(String tempImagePath) async {
    try {
      // Get the app's document directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // Create the directory for profile images if it doesn't exist
      final Directory profileImagesDir = Directory(path.join(appDocDir.path, _profileImagesFolder));
      if (!await profileImagesDir.exists()) { 
        await profileImagesDir.create(recursive: true);
      }

      // Generate a unique file name based on the current timestamp
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(tempImagePath)}';
      final String newImagePath = path.join(profileImagesDir.path, fileName);

      // Copy the image from the temporary location to the permanent one
      final File tempFile = File(tempImagePath);
      final File newFile = await tempFile.copy(newImagePath);

      return newFile.path;
    } catch (e) {
      throw Exception('Error saving image: $e');
    }
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Log error but don't throw - deletion failure shouldn't break the app
    }
  }

  @override
  Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored images (useful for logout/reset)
  @override
  Future<void> clearImages() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory profileImagesDir = Directory(path.join(appDocDir.path, _profileImagesFolder));
      
      if (await profileImagesDir.exists()) {
        await profileImagesDir.delete(recursive: true);
      }
    } catch (e) {
      // Log error but don't throw - clearing images failure shouldn't break the app
    }
  }
}
