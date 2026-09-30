import 'package:equatable/equatable.dart';

import 'space_role.dart';

/// Membership of a signed-in user in a space.
///
/// Stored at `spaces/{spaceId}/members/{uid}`.
class SpaceMemberEntity extends Equatable {
  final String uid;
  final String spaceId;
  final SpaceRole role;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final DateTime joinedAt;

  const SpaceMemberEntity({
    required this.uid,
    required this.spaceId,
    required this.role,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.joinedAt,
  });

  @override
  List<Object?> get props =>
      [uid, spaceId, role, displayName, email, photoUrl, joinedAt];
}
