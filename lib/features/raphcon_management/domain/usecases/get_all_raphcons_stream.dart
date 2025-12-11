import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/raphcon_entity.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class GetAllRaphconsStream {
  final RaphconsRepository repository;

  GetAllRaphconsStream(this.repository);

  Stream<Either<Failure, List<RaphconEntity>>> call() {
    return repository.getAllRaphconsStream();
  }
}
