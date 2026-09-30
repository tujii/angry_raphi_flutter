import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/spaces/data/datasources/spaces_remote_datasource.dart';
import 'package:angry_raphi/features/spaces/domain/entities/invite_code_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_invitation_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:angry_raphi/features/spaces/domain/usecases/invite_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_spaces_repository.dart';

class InviteFakeRepository extends FakeSpacesRepository {
  CreateInviteCodeParams? lastCode;
  String? deletedSpace;
  String? deletedBy;

  @override
  Future<Either<Failure, String>> createInviteCode(
      CreateInviteCodeParams params) async {
    lastCode = params;
    return const Right('code');
  }

  @override
  Future<Either<Failure, void>> deleteSpace(
      String spaceId, String ownerUid) async {
    deletedSpace = spaceId;
    deletedBy = ownerUid;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> joinWithInviteCode(
      InviteCodeEntity invite, MemberProfile profile) async {
    calls.add('join:${invite.code}');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(
      SpaceInvitationEntity invitation, MemberProfile profile) async {
    calls.add('accept:${invitation.id}');
    return const Right(null);
  }
}

InviteCodeEntity invite({bool active = true, DateTime? expiresAt}) =>
    InviteCodeEntity(
      code: 'c1',
      spaceId: 'space1',
      spaceName: 'Team',
      role: SpaceRole.member,
      createdBy: 'a',
      createdAt: DateTime(2024),
      expiresAt: expiresAt,
      active: active,
    );

SpaceInvitationEntity invitation(InvitationStatus status) =>
    SpaceInvitationEntity(
      id: 'inv1',
      spaceId: 'space1',
      spaceName: 'Team',
      email: 'a@b.ch',
      role: SpaceRole.member,
      invitedBy: 'a',
      createdAt: DateTime(2024),
      status: status,
    );

const profile = MemberProfile(uid: 'u1', displayName: 'Max');

void main() {
  late InviteFakeRepository repository;

  setUp(() => repository = InviteFakeRepository());

  group('CreateInviteLink', () {
    test('sets the expiry from validFor', () async {
      final now = DateTime(2024);
      final result = await CreateInviteLink(repository)(
        actor: member('a', SpaceRole.admin),
        spaceName: 'Team',
        role: SpaceRole.member,
        validFor: const Duration(days: 7),
        now: now,
      );

      expect(result, const Right<Failure, String>('code'));
      expect(repository.lastCode!.expiresAt, DateTime(2024, 1, 8));
      expect(repository.lastCode!.createdBy, 'a');
      expect(repository.lastCode!.spaceId, 'space1');
    });

    test('links without validFor never expire', () async {
      await CreateInviteLink(repository)(
        actor: member('a', SpaceRole.admin),
        spaceName: 'Team',
        role: SpaceRole.viewer,
      );
      expect(repository.lastCode!.expiresAt, isNull);
    });

    test('rejects owner links and non-admins', () async {
      final useCase = CreateInviteLink(repository);
      final owner = await useCase(
        actor: member('o', SpaceRole.owner),
        spaceName: 'Team',
        role: SpaceRole.owner,
      );
      final notAdmin = await useCase(
        actor: member('m', SpaceRole.member),
        spaceName: 'Team',
        role: SpaceRole.viewer,
      );
      expect(owner.isLeft(), isTrue);
      expect(notAdmin.isLeft(), isTrue);
      expect(repository.lastCode, isNull);
    });
  });

  group('JoinSpaceWithCode', () {
    final now = DateTime(2024, 6);

    test('joins with a usable link', () async {
      final result = await JoinSpaceWithCode(repository)(
          invite(expiresAt: DateTime(2024, 7)), profile,
          now: now);
      expect(result.isRight(), isTrue);
      expect(repository.calls, ['join:c1']);
    });

    test('rejects expired and deactivated links', () async {
      final useCase = JoinSpaceWithCode(repository);
      final expired = await useCase(
          invite(expiresAt: DateTime(2024, 5)), profile,
          now: now);
      final inactive = await useCase(invite(active: false), profile, now: now);
      expect(expired.isLeft(), isTrue);
      expect(inactive.isLeft(), isTrue);
      expect(repository.calls, isEmpty);
    });
  });

  group('AcceptInvitation', () {
    test('accepts pending invitations only', () async {
      final useCase = AcceptInvitation(repository);
      expect(
          (await useCase(invitation(InvitationStatus.pending), profile))
              .isRight(),
          isTrue);
      expect(
          (await useCase(invitation(InvitationStatus.revoked), profile))
              .isLeft(),
          isTrue);
      expect(repository.calls, ['accept:inv1']);
    });
  });

  group('DeleteSpace', () {
    test('only owners can delete', () async {
      final useCase = DeleteSpace(repository);
      expect((await useCase(member('a', SpaceRole.admin))).isLeft(), isTrue);
      expect(repository.deletedSpace, isNull);

      expect((await useCase(member('o', SpaceRole.owner))).isRight(), isTrue);
      expect(repository.deletedSpace, 'space1');
      expect(repository.deletedBy, 'o');
    });
  });

  group('InviteCodeEntity', () {
    test('isUsableAt respects active flag and expiry', () {
      final now = DateTime(2024, 6);
      expect(invite().isUsableAt(now), isTrue);
      expect(invite(expiresAt: DateTime(2024, 7)).isUsableAt(now), isTrue);
      expect(invite(expiresAt: DateTime(2024, 5)).isUsableAt(now), isFalse);
      expect(invite(active: false).isUsableAt(now), isFalse);
    });
  });

  group('generateInviteCode', () {
    test('creates long random codes without look-alike characters', () {
      final codes = List.generate(
          100, (_) => SpacesRemoteDataSourceImpl.generateInviteCode());
      expect(codes.toSet(), hasLength(100));
      for (final code in codes) {
        expect(code, hasLength(24));
        expect(code, matches(RegExp(r'^[A-Za-z2-9]+$')));
        expect(code, isNot(matches(RegExp('[IlO01]'))));
      }
    });
  });
}
