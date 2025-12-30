import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:netshots/data/services/image/image_storage_service_interface.dart';

class ImageStorageServiceFirebase implements ImageStorageServiceInterface {
  final FirebaseStorage _firebaseStorage;

  ImageStorageServiceFirebase(this._firebaseStorage);

  @override
  Future<String> saveImage(String tempImagePath) async {
    try {
      // Read the original image file
      final File originalFile = File(tempImagePath);
      if (!originalFile.existsSync()) {
        throw Exception('Image file not found at path: $tempImagePath');
      }

      final originalBytes = await originalFile.readAsBytes();

      // Spawn isolate to compress/resize the image
      final compressedBytes = await _compressImageInIsolate(originalBytes);

      // Generate a unique file name
      final fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${originalFile.uri.pathSegments.last}';

      // Upload to Firebase Storage
      final Reference ref = _firebaseStorage.ref(fileName);
      await ref.putData(Uint8List.fromList(compressedBytes));

      // Get and return the download URL
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    try {
      // Extract the path from the download URL or use it directly
      final Reference ref = _firebaseStorage.refFromURL(imagePath);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // Image doesn't exist, consider it as successful deletion
        return;
      }
      throw Exception('Failed to delete image: $e');
    }
  }

  @override
  Future<bool> imageExists(String imagePath) async {
    try {
      final Reference ref = _firebaseStorage.refFromURL(imagePath);
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      throw Exception('Failed to check image existence: $e');
    }
  }

  @override
  Future<void> clearImages() async {
    try {
      final ListResult result = await _firebaseStorage.ref('images').listAll();
      for (final Reference ref in result.items) {
        await ref.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear images: $e');
    }
  }

  /// Compress and resize image in a separate isolate
  static Future<List<int>> _compressImageInIsolate(List<int> imageBytes) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(
      _imageCompressionTask,
      receivePort.sendPort,
    );

    final SendPort sendPort = await receivePort.first as SendPort;
    final ReceivePort responsePort = ReceivePort();

    sendPort.send([imageBytes, responsePort.sendPort]);
    final List<int> compressedBytes = await responsePort.first as List<int>;

    return compressedBytes;
  }

  /// Static function to run in isolate for image compression
  static void _imageCompressionTask(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is List) {
        final List<int> imageBytes = message[0] as List<int>;
        final SendPort responsePort = message[1] as SendPort;

        try {
          // Decode the image
          final img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
          if (originalImage == null) {
            throw Exception('Failed to decode image');
          }

          // Resize if necessary (max width: 1920, max height: 1920)
          img.Image resizedImage = originalImage;
          if (originalImage.width > 1920 || originalImage.height > 1920) {
            resizedImage = img.copyResize(
              originalImage,
              width: originalImage.width > 1920 ? 1920 : null,
              height: originalImage.height > 1920 ? 1920 : null,
              interpolation: img.Interpolation.average,
            );
          }

          // Compress as JPEG with quality 85
          final List<int> compressedBytes =
              img.encodeJpg(resizedImage, quality: 85);

          responsePort.send(compressedBytes);
        } catch (e) {
          // Send empty list or throw - here we send empty as fallback
          responsePort.send([]);
        }
      }
    });
  }
}
