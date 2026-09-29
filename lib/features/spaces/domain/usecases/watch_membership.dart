import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_member_entity.dart';
import '../repositories/spaces_repository.dart';

@injectable
class WatchMembership {
  final SpacesRepository repository;

  WatchMembership(this.repository);

  Stream<Either<Failure, SpaceMemberEntity?>> call(String spaceId, String uid) {
    return repository.watchMembership(spaceId, uid);
  }
}
