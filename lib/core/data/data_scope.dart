import '../constants/firebase_constants.dart';

/// Where persons and raphcons are stored in Firestore.
///
/// The legacy scope uses the global `users` and `raphcons` collections; a
/// space scope uses the subcollections of `spaces/{spaceId}`.
class DataScope {
  /// Id of the space, `null` for the legacy global collections
  final String? spaceId;

  /// Collection path of the rated persons
  final String personsPath;

  /// Collection path of the raphcons
  final String raphconsPath;

  const DataScope._({
    this.spaceId,
    required this.personsPath,
    required this.raphconsPath,
  });

  /// Global collections used before spaces existed
  static const DataScope legacy = DataScope._(
    personsPath: FirebaseConstants.usersCollection,
    raphconsPath: FirebaseConstants.raphconsCollection,
  );

  factory DataScope.space(String spaceId) {
    const spaces = FirebaseConstants.spacesCollection;
    return DataScope._(
      spaceId: spaceId,
      personsPath:
          '$spaces/$spaceId/${FirebaseConstants.spacePersonsCollection}',
      raphconsPath:
          '$spaces/$spaceId/${FirebaseConstants.spaceRaphconsCollection}',
    );
  }

  bool get isSpace => spaceId != null;

  @override
  bool operator ==(Object other) =>
      other is DataScope &&
      other.personsPath == personsPath &&
      other.raphconsPath == raphconsPath;

  @override
  int get hashCode => Object.hash(personsPath, raphconsPath);

  @override
  String toString() => 'DataScope($personsPath, $raphconsPath)';
}
