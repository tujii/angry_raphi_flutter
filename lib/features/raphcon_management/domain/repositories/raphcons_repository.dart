import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/raphcon_entity.dart';

class AddRaphconParams {
  final String userId;
  final String createdBy;
  final String? comment;

  AddRaphconParams({
    required this.userId,
    required this.createdBy,
    this.comment,
  });
}

abstract class RaphconsRepository {
  Future<Either<Failure, List<RaphconEntity>>> getUserRaphcons(String userId);
  Future<Either<Failure, List<RaphconEntity>>> getAllRaphcons();
  Future<Either<Failure, void>> addRaphcon(AddRaphconParams params);
  Future<Either<Failure, void>> deleteRaphcon(String raphconId);
}
