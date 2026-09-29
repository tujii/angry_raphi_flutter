class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String raphconsCollection = 'raphcons';
  static const String adminsCollection = 'admins';

  // Spaces (multi-tenant). Persons and raphcons of a space live in
  // subcollections: spaces/{spaceId}/persons, spaces/{spaceId}/raphcons
  static const String spacesCollection = 'spaces';
  static const String spaceMembersCollection = 'members';
  static const String spacePersonsCollection = 'persons';
  static const String spaceRaphconsCollection = 'raphcons';
  static const String invitationsCollection = 'invitations';

  static const String userImagesPath = 'users';
  static const String raphconImagesPath = 'raphcons';

  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}
