import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/create_space.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/invite_by_email.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/remove_member.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/update_member_role.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/watch_my_invitations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_spaces_repository.dart';

void main() {
  late FakeSpacesRepository repository;

  setUp(() => repository = FakeSpacesRepository());

  group('CreateSpace', () {
    CreateSpaceParams params(String name, {String? description}) =>
        CreateSpaceParams(
          name: name,
          description: description,
          ownerUid: 'uid1',
          ownerDisplayName: 'Max',
        );

    test('trims name and drops empty description', () async {
      final result =
          await CreateSpace(repository)(params('  Team  ', description: ' '));

      expect(result, const Right<Failure, String>('newSpace'));
      expect(repository.lastCreate!.name, 'Team');
      expect(repository.lastCreate!.description, isNull);
    });

    test('rejects empty and too long names', () async {
      expect((await CreateSpace(repository)(params('  '))).isLeft(), isTrue);
      expect(
          (await CreateSpace(repository)(params('x' * 51))).isLeft(), isTrue);
      expect(repository.calls, isEmpty);
    });
  });

  group('UpdateMemberRole', () {
    test('admin can promote a member to admin', () async {
      final result = await UpdateMemberRole(repository)(
        actor: member('a', SpaceRole.admin),
        target: member('m', SpaceRole.member),
        newRole: SpaceRole.admin,
      );

      expect(result.isRight(), isTrue);
      expect(repository.calls, ['updateMemberRole:space1:m:admin']);
    });

    test('admin cannot appoint owners or touch owners', () async {
      final useCase = UpdateMemberRole(repository);
      final appoint = await useCase(
        actor: member('a', SpaceRole.admin),
        target: member('m', SpaceRole.member),
        newRole: SpaceRole.owner,
      );
      final demote = await useCase(
        actor: member('a', SpaceRole.admin),
        target: member('o', SpaceRole.owner),
        newRole: SpaceRole.member,
      );

      expect(appoint.isLeft(), isTrue);
      expect(demote.isLeft(), isTrue);
      expect(repository.calls, isEmpty);
    });

    test('nobody can change their own role', () async {
      final result = await UpdateMemberRole(repository)(
        actor: member('o', SpaceRole.owner),
        target: member('o', SpaceRole.owner),
        newRole: SpaceRole.admin,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('RemoveMember', () {
    test('member can leave', () async {
      final m = member('m', SpaceRole.member);
      final result = await RemoveMember(repository)(actor: m, target: m);

      expect(result.isRight(), isTrue);
      expect(repository.calls, ['removeMember:space1:m']);
    });

    test('owner cannot leave', () async {
      final o = member('o', SpaceRole.owner);
      expect((await RemoveMember(repository)(actor: o, target: o)).isLeft(),
          isTrue);
    });

    test('member cannot remove others', () async {
      final result = await RemoveMember(repository)(
        actor: member('m', SpaceRole.member),
        target: member('v', SpaceRole.viewer),
      );
      expect(result.isLeft(), isTrue);
    });
  });

  group('InviteByEmail', () {
    test('normalizes the email address', () async {
      final result = await InviteByEmail(repository)(
        actor: member('a', SpaceRole.admin),
        spaceName: 'Team',
        email: '  Max@Example.COM ',
        role: SpaceRole.member,
      );

      expect(result.isRight(), isTrue);
      expect(repository.lastInvite!.email, 'max@example.com');
      expect(repository.lastInvite!.invitedBy, 'a');
      expect(repository.lastInvite!.spaceId, 'space1');
    });

    test('rejects invalid emails, owner role and non-admins', () async {
      final useCase = InviteByEmail(repository);
      final invalid = await useCase(
        actor: member('a', SpaceRole.admin),
        spaceName: 'Team',
        email: 'not-an-email',
        role: SpaceRole.member,
      );
      final owner = await useCase(
        actor: member('o', SpaceRole.owner),
        spaceName: 'Team',
        email: 'a@b.ch',
        role: SpaceRole.owner,
      );
      final notAdmin = await useCase(
        actor: member('m', SpaceRole.member),
        spaceName: 'Team',
        email: 'a@b.ch',
        role: SpaceRole.viewer,
      );

      expect(invalid.isLeft(), isTrue);
      expect(owner.isLeft(), isTrue);
      expect(notAdmin.isLeft(), isTrue);
      expect(repository.calls, isEmpty);
    });
  });

  test('WatchMyInvitations normalizes the email address', () {
    WatchMyInvitations(repository)(' Max@Example.com');
    expect(repository.calls, ['watchMyInvitations:max@example.com']);
  });
}
