import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/raphcon_type.dart';
import '../../../../core/errors/failures.dart';
import '../entities/raphcon_entity.dart';
import '../repositories/raphcons_repository.dart';

@injectable
class GetUserRaphconsByType {
  final RaphconsRepository repository;

  GetUserRaphconsByType(this.repository);

  Future<Either<Failure, List<RaphconEntity>>> call(
      String userId, RaphconType type) async {
    return repository.getUserRaphconsByType(userId, type);
  }
}
