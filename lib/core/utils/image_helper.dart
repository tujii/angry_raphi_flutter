import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// Helper class for image selection and validation.
///
/// Provides methods to pick images from gallery or camera,
/// and validate image file properties such as type and size.
/// Uses the [image_picker] package for cross-platform image selection.
@injectable
class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device gallery.
  ///
  /// Opens the gallery picker and allows the user to select an image.
  /// The selected image is automatically compressed and resized.
  ///
  /// Image processing settings:
  /// - Quality: 80% compression
  /// - Max dimensions: 1024x1024 pixels
  ///
  /// Returns a [File] object if an image was selected, or `null` if
  /// the user cancelled the selection.
  ///
  /// Throws an [Exception] if there's an error accessing the gallery.
  ///
  /// Example:
  /// ```dart
  /// final imageHelper = ImageHelper();
  /// final image = await imageHelper.pickImageFromGallery();
  /// if (image != null) {
  ///   print('Image selected: ${image.path}');
  /// }
  /// ```
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Picks an image from the device camera.
  ///
  /// Opens the camera and allows the user to take a photo.
  /// The captured image is automatically compressed and resized.
  ///
  /// Image processing settings:
  /// - Quality: 80% compression
  /// - Max dimensions: 1024x1024 pixels
  ///
  /// Returns a [File] object if a photo was taken, or `null` if
  /// the user cancelled.
  ///
  /// Throws an [Exception] if there's an error accessing the camera.
  ///
  /// Example:
  /// ```dart
  /// final imageHelper = ImageHelper();
  /// final image = await imageHelper.pickImageFromCamera();
  /// if (image != null) {
  ///   print('Photo captured: ${image.path}');
  /// }
  /// ```
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  /// Validates that an image file size is within acceptable limits.
  ///
  /// Checks if the file size is 5MB or less.
  ///
  /// Parameters:
  /// - [imageFile]: The image file to validate
  ///
  /// Returns `true` if the file size is acceptable, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isValid = imageHelper.isValidImageSize(imageFile);
  /// if (!isValid) {
  ///   print('File is too large');
  /// }
  /// ```
  bool isValidImageSize(File imageFile) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    return imageFile.lengthSync() <= maxSizeInBytes;
  }

  /// Validates that a file has an acceptable image extension.
  ///
  /// Checks if the file extension is one of: jpg, jpeg, png, webp.
  /// Case-insensitive comparison.
  ///
  /// Parameters:
  /// - [fileName]: The name of the file to validate
  ///
  /// Returns `true` if the extension is acceptable, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isValid = imageHelper.isValidImageType('photo.jpg');
  /// if (!isValid) {
  ///   print('Unsupported file type');
  /// }
  /// ```
  bool isValidImageType(String fileName) {
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final extension = fileName.toLowerCase().split('.').last;
    return allowedExtensions.contains(extension);
  }
}
