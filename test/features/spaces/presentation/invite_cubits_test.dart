import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/invite_usecases.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_membership.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_my_invitations.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/join_space_cubit.dart';
import 'package:angry_raphi/features/spaces/presentation/cubit/my_invitations_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stream_spaces_repository.dart';

Future<void> pump() => Future<void>.delayed(Duration.zero);

const profile = MemberProfile(uid: 'uid1', displayName: 'Max');

void main() {
  late StreamSpacesRepository repository;
  late JoinSpaceCubit cubit;

  setUp(() {
    repository = StreamSpacesRepository();
    cubit = JoinSpaceCubit(
      GetInviteCode(repository),
      WatchMembership(repository),
      JoinSpaceWithCode(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  group('JoinSpaceCubit', () {
    test('members go straight to the space', () async {
      final loading = cubit.load('space1', 'code', 'uid1');
      repository.membership.add(Right(testMember(SpaceRole.member)));
      await loading;

      expect(cubit.state, const JoinSpaceJoined('space1'));
    });

    test('a denied membership read counts as not a member', () async {
      repository.inviteCode = Right(testInvite());
      final loading = cubit.load('space1', 'code', 'uid1');
      repository.membership.add(const Left(ServerFailure('permission')));
      await loading;

      expect(cubit.state, JoinSpaceReady(testInvite()));
    });

    test('unknown, expired and deactivated links are invalid', () async {
      for (final code in [
        null,
        testInvite(active: false),
        testInvite(expiresAt: DateTime(2000)),
      ]) {
        repository.inviteCode = Right(code);
        final loading = cubit.load('space1', 'code', 'uid1');
        repository.membership.add(const Right(null));
        await loading;
        expect(cubit.state, const JoinSpaceInvalid(), reason: '$code');
      }
    });

    test('joining uses the link and ends in the space', () async {
      repository.inviteCode = Right(testInvite());
      final loading = cubit.load('space1', 'code', 'uid1');
      repository.membership.add(const Right(null));
      await loading;

      await cubit.join(profile);

      expect(cubit.state, const JoinSpaceJoined('space1'));
      expect(repository.joinedWith, testInvite());
      expect(repository.joinedAs, profile);
    });
  });

  group('MyInvitationsCubit', () {
    test('lists invitations and accepts them', () async {
      final invitations = MyInvitationsCubit(
        WatchMyInvitations(repository),
        AcceptInvitation(repository),
        DeclineInvitation(repository),
      )..watch('Max@Example.com');

      repository.myInvitations.add(Right([testInvitation]));
      await pump();
      expect(invitations.state, [testInvitation]);

      expect(await invitations.accept(testInvitation, profile), isNull);
      expect(repository.accepted, testInvitation);

      repository.myInvitations.add(const Left(ServerFailure('offline')));
      await pump();
      expect(invitations.state, isEmpty);

      await invitations.close();
    });
  });
}
