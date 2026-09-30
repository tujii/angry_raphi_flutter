import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_member_entity.dart';
import '../entities/space_role.dart';
import '../repositories/spaces_repository.dart';

@injectable
class UpdateMemberRole {
  final SpacesRepository repository;

  UpdateMemberRole(this.repository);

  /// [actor] is the membership of the user performing the change.
  Future<Either<Failure, void>> call({
    required SpaceMemberEntity actor,
    required SpaceMemberEntity target,
    required SpaceRole newRole,
  }) async {
    if (actor.uid == target.uid) {
      return const Left(PermissionFailure('You cannot change your own role'));
    }
    if (!actor.role.canManageMemberWithRole(target.role) ||
        !actor.role.assignableRoles.contains(newRole)) {
      return const Left(
          PermissionFailure('Not allowed to assign this role to this member'));
    }
    return repository.updateMemberRole(target.spaceId, target.uid, newRole);
  }
}
