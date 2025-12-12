import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, bool>> checkAdminStatus(String email);
  Future<Either<Failure, void>> addAdmin(
      String userId, String email, String displayName);
  Future<Either<Failure, void>> removeAdmin(String email);
  Future<Either<Failure, List<AdminEntity>>> getAllAdmins();
}
