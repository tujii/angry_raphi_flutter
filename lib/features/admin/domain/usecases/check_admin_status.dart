import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@injectable
class CheckAdminStatus {
  final AdminRepository repository;

  CheckAdminStatus(this.repository);

  Future<Either<Failure, bool>> call(String email) async {
    return repository.checkAdminStatus(email);
  }
}
