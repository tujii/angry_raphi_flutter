import 'dart:async';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/invite_code_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_invitation_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_member_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/invite_by_email.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/invite_usecases.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/remove_member.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/update_member_role.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_space_members.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/space_admin_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stream_spaces_repository.dart';

class AdminRepository extends StreamSpacesRepository {
  final members =
      StreamController<Either<Failure, List<SpaceMemberEntity>>>.broadcast();
  final codes =
      StreamController<Either<Failure, List<InviteCodeEntity>>>.broadcast();
  final invitations = StreamController<
      Either<Failure, List<SpaceInvitationEntity>>>.broadcast();
  int adminSubscriptions = 0;
  final List<String> calls = [];

  @override
  Stream<Either<Failure, List<SpaceMemberEntity>>> watchMembers(
          String spaceId) =>
      members.stream;

  @override
  Stream<Either<Failure, List<InviteCodeEntity>>> watchInviteCodes(
      String spaceId) {
    adminSubscriptions++;
    return codes.stream;
  }

  @override
  Stream<Either<Failure, List<SpaceInvitationEntity>>> watchSpaceInvitations(
      String spaceId) {
    adminSubscriptions++;
    return invitations.stream;
  }

  @override
  Future<Either<Failure, void>> removeMember(String spaceId, String uid) async {
    calls.add('remove:$uid');
    return const Right(null);
  }

  @override
  void dispose() {
    super.dispose();
    unawaited(members.close());
    unawaited(codes.close());
    unawaited(invitations.close());
  }
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late AdminRepository repository;
  late SpaceAdminCubit cubit;

  setUp(() {
    repository = AdminRepository();
    cubit = SpaceAdminCubit(
      watchMembers: WatchSpaceMembers(repository),
      watchInviteCodes: WatchInviteCodes(repository),
      watchInvitations: WatchSpaceInvitations(repository),
      updateMemberRole: UpdateMemberRole(repository),
      removeMember: RemoveMember(repository),
      createInviteLink: CreateInviteLink(repository),
      deactivateInviteCode: DeactivateInviteCode(repository),
      inviteByEmail: InviteByEmail(repository),
      revokeInvitation: RevokeInvitation(repository),
      deleteSpace: DeleteSpace(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  test('members only see the member list', () async {
    cubit.watch(testMember(SpaceRole.member));
    repository.members.add(Right([testMember(SpaceRole.member)]));
    await pump();

    expect(cubit.state.members, [testMember(SpaceRole.member)]);
    expect(repository.adminSubscriptions, 0);
  });

  test('admins see active invite links and invitations', () async {
    cubit.watch(testMember(SpaceRole.admin));
    repository.codes.add(Right([testInvite(), testInvite(active: false)]));
    repository.invitations.add(Right([testInvitation]));
    await pump();

    expect(cubit.state.inviteCodes, [testInvite()]);
    expect(cubit.state.invitations, [testInvitation]);
  });

  test('promotion to admin starts watching invitations', () async {
    cubit.watch(testMember(SpaceRole.member));
    expect(repository.adminSubscriptions, 0);

    cubit.watch(testMember(SpaceRole.admin));
    expect(repository.adminSubscriptions, 2);

    // Unrelated updates do not re-subscribe
    cubit.watch(testMember(SpaceRole.owner));
    expect(repository.adminSubscriptions, 2);
  });

  test('leaving removes the own membership, owners cannot leave', () async {
    cubit.watch(testMember(SpaceRole.member));
    expect(await cubit.leave(), isNull);
    expect(repository.calls, ['remove:uid1']);

    cubit.watch(testMember(SpaceRole.owner));
    expect(await cubit.leave(), isNotNull);
    expect(repository.calls, ['remove:uid1']);
  });
}
