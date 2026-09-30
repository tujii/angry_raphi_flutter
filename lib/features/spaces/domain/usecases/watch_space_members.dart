import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_member_entity.dart';
import '../repositories/spaces_repository.dart';

@injectable
class WatchSpaceMembers {
  final SpacesRepository repository;

  WatchSpaceMembers(this.repository);

  Stream<Either<Failure, List<SpaceMemberEntity>>> call(String spaceId) {
    return repository.watchMembers(spaceId);
  }
}
