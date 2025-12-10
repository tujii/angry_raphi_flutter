import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

@injectable
class AddAdmin {
  final AdminRepository repository;

  AddAdmin(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    return await repository.addAdmin(userId, email, displayName);
  }
}
