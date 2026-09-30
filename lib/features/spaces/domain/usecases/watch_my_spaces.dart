import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/space_entity.dart';
import '../repositories/spaces_repository.dart';

@injectable
class WatchMySpaces {
  final SpacesRepository repository;

  WatchMySpaces(this.repository);

  Stream<Either<Failure, List<SpaceEntity>>> call(String uid) {
    return repository.watchMySpaces(uid);
  }
}
