import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invite_code_entity.dart';
import '../entities/space_invitation_entity.dart';
import '../entities/space_member_entity.dart';
import '../entities/space_role.dart';
import '../repositories/spaces_repository.dart';

/// Creates an invite link; [validFor] `null` means it never expires.
@injectable
class CreateInviteLink {
  final SpacesRepository repository;

  CreateInviteLink(this.repository);

  Future<Either<Failure, String>> call({
    required SpaceMemberEntity actor,
    required String spaceName,
    required SpaceRole role,
    Duration? validFor,
    DateTime? now,
  }) async {
    // Ownership is transferred explicitly, never via invitation.
    if (role == SpaceRole.owner || !actor.role.assignableRoles.contains(role)) {
      return const Left(
          PermissionFailure('Not allowed to invite with this role'));
    }
    return repository.createInviteCode(CreateInviteCodeParams(
      spaceId: actor.spaceId,
      spaceName: spaceName,
      role: role,
      createdBy: actor.uid,
      expiresAt:
          validFor == null ? null : (now ?? DateTime.now()).add(validFor),
    ));
  }
}

@injectable
class WatchInviteCodes {
  final SpacesRepository repository;

  WatchInviteCodes(this.repository);

  Stream<Either<Failure, List<InviteCodeEntity>>> call(String spaceId) {
    return repository.watchInviteCodes(spaceId);
  }
}

@injectable
class DeactivateInviteCode {
  final SpacesRepository repository;

  DeactivateInviteCode(this.repository);

  Future<Either<Failure, void>> call(InviteCodeEntity invite) {
    return repository.deactivateInviteCode(invite.spaceId, invite.code);
  }
}

@injectable
class GetInviteCode {
  final SpacesRepository repository;

  GetInviteCode(this.repository);

  Future<Either<Failure, InviteCodeEntity?>> call(String spaceId, String code) {
    return repository.getInviteCode(spaceId, code);
  }
}

@injectable
class JoinSpaceWithCode {
  final SpacesRepository repository;

  JoinSpaceWithCode(this.repository);

  Future<Either<Failure, void>> call(
    InviteCodeEntity invite,
    MemberProfile profile, {
    DateTime? now,
  }) async {
    if (!invite.isUsableAt(now ?? DateTime.now())) {
      return const Left(
          ValidationFailure('This invite link is no longer valid'));
    }
    return repository.joinWithInviteCode(invite, profile);
  }
}

@injectable
class AcceptInvitation {
  final SpacesRepository repository;

  AcceptInvitation(this.repository);

  Future<Either<Failure, void>> call(
      SpaceInvitationEntity invitation, MemberProfile profile) async {
    if (invitation.status != InvitationStatus.pending) {
      return const Left(
          ValidationFailure('This invitation is no longer valid'));
    }
    return repository.acceptInvitation(invitation, profile);
  }
}

@injectable
class DeclineInvitation {
  final SpacesRepository repository;

  DeclineInvitation(this.repository);

  Future<Either<Failure, void>> call(SpaceInvitationEntity invitation) {
    return repository.declineInvitation(invitation.id);
  }
}

@injectable
class RevokeInvitation {
  final SpacesRepository repository;

  RevokeInvitation(this.repository);

  Future<Either<Failure, void>> call(SpaceInvitationEntity invitation) {
    return repository.revokeInvitation(invitation.id);
  }
}

@injectable
class WatchSpaceInvitations {
  final SpacesRepository repository;

  WatchSpaceInvitations(this.repository);

  Stream<Either<Failure, List<SpaceInvitationEntity>>> call(String spaceId) {
    return repository.watchSpaceInvitations(spaceId);
  }
}

@injectable
class DeleteSpace {
  final SpacesRepository repository;

  DeleteSpace(this.repository);

  Future<Either<Failure, void>> call(SpaceMemberEntity actor) async {
    if (!actor.role.canDeleteSpace) {
      return const Left(PermissionFailure('Only owners can delete the space'));
    }
    return repository.deleteSpace(actor.spaceId, actor.uid);
  }
}
