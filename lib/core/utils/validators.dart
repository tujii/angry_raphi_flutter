/// Utility class for input validation throughout the application.
///
/// Provides static methods for validating common input types such as
/// email addresses, names, descriptions, and file uploads.
class Validators {
  /// Validates an email address.
  ///
  /// Returns an error message if the email is invalid or null,
  /// otherwise returns null indicating the email is valid.
  ///
  /// Validation rules:
  /// - Email cannot be null or empty
  /// - Must match standard email format (user@domain.tld)
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.validateEmail('user@example.com');
  /// if (error != null) {
  ///   print('Invalid email: $error');
  /// }
  /// ```
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // More robust email regex pattern that handles special characters like +
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates a person's name.
  ///
  /// Returns an error message if the name is invalid or null,
  /// otherwise returns null indicating the name is valid.
  ///
  /// Validation rules:
  /// - Name cannot be null or empty
  /// - Must be at least 2 characters long
  /// - Cannot exceed 50 characters
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.validateName('John Doe');
  /// if (error != null) {
  ///   print('Invalid name: $error');
  /// }
  /// ```
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  /// Validates a description text field.
  ///
  /// Returns an error message if the description exceeds the maximum length,
  /// otherwise returns null. Note that empty descriptions are considered valid.
  ///
  /// Validation rules:
  /// - Cannot exceed 500 characters
  /// - Empty or null values are allowed
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.validateDescription('Some description');
  /// if (error != null) {
  ///   print('Invalid description: $error');
  /// }
  /// ```
  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }

  /// Validates that a required field is not empty.
  ///
  /// Returns an error message using the provided [fieldName] if the value
  /// is null or empty, otherwise returns null.
  ///
  /// Parameters:
  /// - [value]: The value to validate
  /// - [fieldName]: The name of the field for the error message
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.validateRequired('', 'Username');
  /// if (error != null) {
  ///   print('Error: $error'); // Prints: "Error: Username is required"
  /// }
  /// ```
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Checks if a file has a valid image type extension.
  ///
  /// Returns `true` if the file extension is one of the allowed image types,
  /// otherwise returns `false`.
  ///
  /// Allowed extensions: jpg, jpeg, png, webp
  ///
  /// Example:
  /// ```dart
  /// final isValid = Validators.isValidImageType('photo.jpg');
  /// print(isValid); // true
  /// ```
  static bool isValidImageType(String fileName) {
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final extension = fileName.toLowerCase().split('.').last;
    return allowedExtensions.contains(extension);
  }

  /// Checks if an image file size is within the allowed limit.
  ///
  /// Returns `true` if the file size is 5MB or less, otherwise returns `false`.
  ///
  /// Parameters:
  /// - [fileSizeInBytes]: The size of the file in bytes
  ///
  /// Example:
  /// ```dart
  /// final isValid = Validators.isValidImageSize(1024 * 1024); // 1MB
  /// print(isValid); // true
  /// ```
  static bool isValidImageSize(int fileSizeInBytes) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    return fileSizeInBytes <= maxSizeInBytes;
  }
}
