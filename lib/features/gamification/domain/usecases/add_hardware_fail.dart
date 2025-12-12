import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../repositories/gamification_repository.dart';

/// Use case for adding a hardware fail
class AddHardwareFail {
  final GamificationRepository repository;

  AddHardwareFail(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required RaphconType type,
  }) async {
    return await repository.addHardwareFail(
      userId: userId,
      type: type,
    );
  }
}
