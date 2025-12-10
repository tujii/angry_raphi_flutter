import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/users_repository.dart';

@injectable
class SavePerson {
  final UsersRepository repository;

  SavePerson(this.repository);

  Future<Either<Failure, void>> call(AddPersonParams params) async {
    return await repository.addPerson(params);
  }
}
