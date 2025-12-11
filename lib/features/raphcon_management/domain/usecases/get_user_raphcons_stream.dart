import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/raphcon_entity.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class GetUserRaphconsStream {
  final RaphconsRepository repository;

  GetUserRaphconsStream(this.repository);

  Stream<Either<Failure, List<RaphconEntity>>> call(String userId) {
    return repository.getUserRaphconsStream(userId);
  }
}
