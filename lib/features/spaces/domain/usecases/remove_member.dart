import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_member_entity.dart';
import '../entities/space_role.dart';
import '../repositories/spaces_repository.dart';

@injectable
class RemoveMember {
  final SpacesRepository repository;

  RemoveMember(this.repository);

  /// Removes [target] from its space. When [actor] and [target] are the same
  /// user this means leaving the space, which owners cannot do (they have to
  /// hand over ownership first).
  Future<Either<Failure, void>> call({
    required SpaceMemberEntity actor,
    required SpaceMemberEntity target,
  }) async {
    final leaving = actor.uid == target.uid;
    if (leaving && actor.role == SpaceRole.owner) {
      return const Left(PermissionFailure(
          'Owners must transfer ownership before leaving the space'));
    }
    if (!leaving && !actor.role.canManageMemberWithRole(target.role)) {
      return const Left(PermissionFailure('Not allowed to remove this member'));
    }
    return repository.removeMember(target.spaceId, target.uid);
  }
}
