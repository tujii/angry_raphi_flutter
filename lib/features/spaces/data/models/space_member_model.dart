import '../../domain/entities/space_member_entity.dart';
import '../../domain/entities/space_role.dart';
import 'firestore_date.dart';

class SpaceMemberModel extends SpaceMemberEntity {
  const SpaceMemberModel({
    required super.uid,
    required super.spaceId,
    required super.role,
    required super.displayName,
    super.email,
    super.photoUrl,
    required super.joinedAt,
  });

  factory SpaceMemberModel.fromMap(Map<String, dynamic> map, String uid) {
    return SpaceMemberModel(
      uid: uid,
      spaceId: map['spaceId'] as String? ?? '',
      role: SpaceRole.fromString(map['role'] as String?),
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      joinedAt: firestoreDate(map['joinedAt']),
    );
  }

  /// Fields written on creation; `joinedAt` is set by the data source.
  /// `uid` and `spaceId` are duplicated into the document so that a
  /// collection-group query can find all memberships of a user.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'spaceId': spaceId,
      'role': role.value,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
