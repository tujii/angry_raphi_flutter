import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_invitation_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_member_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:dartz/dartz.dart';

/// Records calls; only the methods used by the use case tests are implemented.
class FakeSpacesRepository implements SpacesRepository {
  final List<String> calls = [];
  CreateSpaceParams? lastCreate;
  InviteByEmailParams? lastInvite;

  @override
  Future<Either<Failure, String>> createSpace(CreateSpaceParams params) async {
    calls.add('createSpace');
    lastCreate = params;
    return const Right('newSpace');
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
      String spaceId, String uid, SpaceRole role) async {
    calls.add('updateMemberRole:$spaceId:$uid:${role.value}');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeMember(String spaceId, String uid) async {
    calls.add('removeMember:$spaceId:$uid');
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> inviteByEmail(
      InviteByEmailParams params) async {
    calls.add('inviteByEmail');
    lastInvite = params;
    return const Right('inv1');
  }

  @override
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchMyInvitations(
      String email) {
    calls.add('watchMyInvitations:$email');
    return const Stream.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

SpaceMemberEntity member(String uid, SpaceRole role) => SpaceMemberEntity(
      uid: uid,
      spaceId: 'space1',
      role: role,
      displayName: uid,
      joinedAt: DateTime(2024),
    );
