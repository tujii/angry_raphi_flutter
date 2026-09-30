import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_invitation_entity.dart';
import '../repositories/spaces_repository.dart';

@injectable
class WatchMyInvitations {
  final SpacesRepository repository;

  WatchMyInvitations(this.repository);

  Stream<Either<Failure, List<SpaceInvitationEntity>>> call(String email) {
    return repository.watchMyInvitations(email.trim().toLowerCase());
  }
}
