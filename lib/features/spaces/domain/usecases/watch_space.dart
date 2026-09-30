import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_entity.dart';
import '../repositories/spaces_repository.dart';

@injectable
class WatchSpace {
  final SpacesRepository repository;

  WatchSpace(this.repository);

  Stream<Either<Failure, SpaceEntity?>> call(String spaceId) {
    return repository.watchSpace(spaceId);
  }
}
