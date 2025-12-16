import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/raphcon_type.dart';
import '../../../../core/errors/failures.dart';
import '../entities/raphcon_entity.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class GetUserRaphconsByTypeStream {
  final RaphconsRepository repository;

  GetUserRaphconsByTypeStream(this.repository);

  Stream<Either<Failure, List<RaphconEntity>>> call(
      String userId, RaphconType type) {
    return repository.getUserRaphconsByTypeStream(userId, type);
  }
}
