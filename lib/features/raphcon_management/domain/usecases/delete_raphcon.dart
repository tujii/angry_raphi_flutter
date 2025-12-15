import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class DeleteRaphcon {
  final RaphconsRepository repository;

  DeleteRaphcon(this.repository);

  Future<Either<Failure, void>> call(String raphconId) async {
    return repository.deleteRaphcon(raphconId);
  }
}
