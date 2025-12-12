import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class ExpireOldRaphcons {
  final RaphconsRepository repository;

  ExpireOldRaphcons(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.expireOldRaphcons();
  }
}
