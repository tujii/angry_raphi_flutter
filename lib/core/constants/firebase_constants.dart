class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String raphconsCollection = 'raphcons';
  static const String adminsCollection = 'admins';
  static const String hardwareFailsCollection = 'hardwareFails';
  static const String storiesCollection = 'stories';

  static const String userImagesPath = 'users';
  static const String raphconImagesPath = 'raphcons';

  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}
