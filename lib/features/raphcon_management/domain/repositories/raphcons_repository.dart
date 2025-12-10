import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../entities/raphcon_entity.dart';

class AddRaphconParams {
  final String userId;
  final String createdBy;
  final String? comment;
  final RaphconType type;

  AddRaphconParams({
    required this.userId,
    required this.createdBy,
    this.comment,
    this.type = RaphconType.other,
  });
}

abstract class RaphconsRepository {
  Future<Either<Failure, List<RaphconEntity>>> getUserRaphcons(String userId);
  Future<Either<Failure, List<RaphconEntity>>> getUserRaphconsByType(
      String userId, RaphconType type);
  Future<Either<Failure, List<RaphconEntity>>> getAllRaphcons();
  Future<Either<Failure, void>> addRaphcon(AddRaphconParams params);
  Future<Either<Failure, void>> deleteRaphcon(String raphconId);
}
