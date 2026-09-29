import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_entity.dart';
import '../entities/space_invitation_entity.dart';
import '../entities/space_member_entity.dart';
import '../entities/space_role.dart';

class CreateSpaceParams {
  final String name;
  final String? description;
  final String ownerUid;
  final String ownerDisplayName;
  final String? ownerEmail;
  final String? ownerPhotoUrl;

  const CreateSpaceParams({
    required this.name,
    this.description,
    required this.ownerUid,
    required this.ownerDisplayName,
    this.ownerEmail,
    this.ownerPhotoUrl,
  });
}

class InviteByEmailParams {
  final String spaceId;
  final String spaceName;
  final String email;
  final SpaceRole role;
  final String invitedBy;

  const InviteByEmailParams({
    required this.spaceId,
    required this.spaceName,
    required this.email,
    required this.role,
    required this.invitedBy,
  });
}

abstract class SpacesRepository {
  /// Creates a space and makes the creator its owner. Returns the new space id.
  Future<Either<Failure, String>> createSpace(CreateSpaceParams params);

  Future<Either<Failure, void>> updateSpace(
    String spaceId, {
    required String name,
    String? description,
  });

  Future<Either<Failure, void>> deleteSpace(String spaceId);

  /// All spaces the user with [uid] is a member of, sorted by name.
  Stream<Either<Failure, List<SpaceEntity>>> watchMySpaces(String uid);

  /// The space with [spaceId]; `null` if it does not exist.
  Stream<Either<Failure, SpaceEntity?>> watchSpace(String spaceId);

  /// The membership of [uid] in [spaceId]; `null` if not a member.
  Stream<Either<Failure, SpaceMemberEntity?>> watchMembership(
      String spaceId, String uid);

  Stream<Either<Failure, List<SpaceMemberEntity>>> watchMembers(String spaceId);

  Future<Either<Failure, void>> updateMemberRole(
      String spaceId, String uid, SpaceRole role);

  /// Removes a member; also used to leave a space (own [uid]).
  Future<Either<Failure, void>> removeMember(String spaceId, String uid);

  Future<Either<Failure, String>> inviteByEmail(InviteByEmailParams params);

  Future<Either<Failure, void>> revokeInvitation(String invitationId);

  Future<Either<Failure, void>> declineInvitation(String invitationId);

  /// Pending invitations of a space (for its admins).
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchSpaceInvitations(
      String spaceId);

  /// Pending invitations addressed to [email] (for the invitee).
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchMyInvitations(
      String email);
}
