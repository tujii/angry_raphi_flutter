import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class AddRaphcon {
  final RaphconsRepository repository;

  AddRaphcon(this.repository);

  Future<Either<Failure, void>> call(AddRaphconParams params) async {
    return await repository.addRaphcon(params);
  }
}
