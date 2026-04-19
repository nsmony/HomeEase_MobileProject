import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class StorageService {
  /// Picks an image from gallery and returns it as a base64 string.
  /// This avoids Firebase Storage (which requires Blaze plan).
  /// The base64 string is saved directly to Firestore (free).
  Future<String?> pickProfilePictureAsBase64() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70, // Compress to keep Firestore doc size small
    );
    if (image == null) return null;

    try {
      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }
}