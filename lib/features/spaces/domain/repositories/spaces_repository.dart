import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invite_code_entity.dart';
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

/// Profile of the signed-in user, copied into their membership.
class MemberProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;

  const MemberProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
  });
}

class CreateInviteCodeParams {
  final String spaceId;
  final String spaceName;
  final SpaceRole role;
  final String createdBy;
  final DateTime? expiresAt;

  const CreateInviteCodeParams({
    required this.spaceId,
    required this.spaceName,
    required this.role,
    required this.createdBy,
    this.expiresAt,
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

  /// Deletes the space with all persons, raphcons, invitations and
  /// memberships. [ownerUid] is the owner performing the deletion; their
  /// membership is removed last, together with the space.
  Future<Either<Failure, void>> deleteSpace(String spaceId, String ownerUid);

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

  /// Creates an invite link and returns its code.
  Future<Either<Failure, String>> createInviteCode(
      CreateInviteCodeParams params);

  /// Invite links of a space (for its admins), newest first.
  Stream<Either<Failure, List<InviteCodeEntity>>> watchInviteCodes(
      String spaceId);

  Future<Either<Failure, void>> deactivateInviteCode(
      String spaceId, String code);

  /// The invite link; `null` if it does not exist.
  Future<Either<Failure, InviteCodeEntity?>> getInviteCode(
      String spaceId, String code);

  /// Joins [invite]'s space with the role of the link.
  Future<Either<Failure, void>> joinWithInviteCode(
      InviteCodeEntity invite, MemberProfile profile);

  /// Joins the invitation's space and marks the invitation accepted.
  Future<Either<Failure, void>> acceptInvitation(
      SpaceInvitationEntity invitation, MemberProfile profile);
}
