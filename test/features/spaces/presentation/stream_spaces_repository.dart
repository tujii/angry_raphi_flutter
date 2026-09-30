import 'dart:async';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/invite_code_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_invitation_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_member_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:dartz/dartz.dart';

/// Test repository whose streams are driven by the test.
class StreamSpacesRepository implements SpacesRepository {
  final mySpaces = StreamController<Either<Failure, List<SpaceEntity>>>();
  final space = StreamController<Either<Failure, SpaceEntity?>>();
  // Broadcast: like Firestore, several pages may watch the membership.
  final membership =
      StreamController<Either<Failure, SpaceMemberEntity?>>.broadcast();
  final myInvitations =
      StreamController<Either<Failure, List<SpaceInvitationEntity>>>();

  Either<Failure, InviteCodeEntity?> inviteCode = const Right(null);
  InviteCodeEntity? joinedWith;
  SpaceInvitationEntity? accepted;
  MemberProfile? joinedAs;

  CreateSpaceParams? lastCreate;
  Either<Failure, String> createResult = const Right('newSpace');
  int spaceSubscriptions = 0;

  @override
  Stream<Either<Failure, List<SpaceEntity>>> watchMySpaces(String uid) =>
      mySpaces.stream;

  @override
  Stream<Either<Failure, SpaceEntity?>> watchSpace(String spaceId) {
    spaceSubscriptions++;
    return space.stream;
  }

  @override
  Stream<Either<Failure, SpaceMemberEntity?>> watchMembership(
          String spaceId, String uid) =>
      membership.stream;

  @override
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchMyInvitations(
          String email) =>
      myInvitations.stream;

  @override
  Future<Either<Failure, InviteCodeEntity?>> getInviteCode(
          String spaceId, String code) async =>
      inviteCode;

  @override
  Future<Either<Failure, void>> joinWithInviteCode(
      InviteCodeEntity invite, MemberProfile profile) async {
    joinedWith = invite;
    joinedAs = profile;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(
      SpaceInvitationEntity invitation, MemberProfile profile) async {
    accepted = invitation;
    joinedAs = profile;
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> createSpace(CreateSpaceParams params) async {
    lastCreate = params;
    return createResult;
  }

  /// Not awaited: closing a controller that was never listened to
  /// never completes.
  void dispose() {
    unawaited(mySpaces.close());
    unawaited(space.close());
    unawaited(membership.close());
    unawaited(myInvitations.close());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

final testSpace = SpaceEntity(
  id: 'space1',
  name: 'Team Rocket',
  description: 'Prepare for trouble',
  createdBy: 'uid1',
  createdAt: DateTime(2024),
);

SpaceMemberEntity testMember(SpaceRole role) => SpaceMemberEntity(
      uid: 'uid1',
      spaceId: 'space1',
      role: role,
      displayName: 'Max',
      joinedAt: DateTime(2024),
    );

InviteCodeEntity testInvite({
  bool active = true,
  DateTime? expiresAt,
  SpaceRole role = SpaceRole.member,
}) =>
    InviteCodeEntity(
      code: 'abcdefghijklmnopqrstuvwx',
      spaceId: 'space1',
      spaceName: 'Team Rocket',
      role: role,
      createdBy: 'admin',
      createdAt: DateTime(2024),
      expiresAt: expiresAt,
      active: active,
    );

final testInvitation = SpaceInvitationEntity(
  id: 'inv1',
  spaceId: 'space1',
  spaceName: 'Team Rocket',
  email: 'max@example.com',
  role: SpaceRole.member,
  invitedBy: 'admin',
  createdAt: DateTime(2024),
);
