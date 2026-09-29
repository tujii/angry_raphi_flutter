import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_member_entity.dart';
import '../entities/space_role.dart';
import '../repositories/spaces_repository.dart';

@injectable
class InviteByEmail {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final SpacesRepository repository;

  InviteByEmail(this.repository);

  Future<Either<Failure, String>> call({
    required SpaceMemberEntity actor,
    required String spaceName,
    required String email,
    required SpaceRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      return const Left(ValidationFailure('Invalid email address'));
    }
    // Ownership is transferred explicitly, never via invitation.
    if (role == SpaceRole.owner || !actor.role.assignableRoles.contains(role)) {
      return const Left(
          PermissionFailure('Not allowed to invite with this role'));
    }
    return repository.inviteByEmail(InviteByEmailParams(
      spaceId: actor.spaceId,
      spaceName: spaceName,
      email: normalizedEmail,
      role: role,
      invitedBy: actor.uid,
    ));
  }
}
