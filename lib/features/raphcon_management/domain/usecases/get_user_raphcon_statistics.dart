import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../repositories/raphcons_repository.dart';

/// Use case to get raphcon statistics for a specific user
/// Returns a map with RaphconType as key and count as value
@injectable
class GetUserRaphconStatistics {
  final RaphconsRepository repository;

  GetUserRaphconStatistics(this.repository);

  Future<Either<Failure, Map<RaphconType, int>>> call(String userId) async {
    final result = await repository.getUserRaphcons(userId);

    return result.fold(
      (failure) => Left(failure),
      (raphcons) {
        // Count raphcons by type
        final statistics = <RaphconType, int>{};

        // Initialize all types with 0
        for (final type in RaphconType.values) {
          statistics[type] = 0;
        }

        // Count actual raphcons
        for (final raphcon in raphcons) {
          statistics[raphcon.type] = (statistics[raphcon.type] ?? 0) + 1;
        }

        // Remove types with 0 count for cleaner display
        statistics.removeWhere((key, value) => value == 0);

        return Right(statistics);
      },
    );
  }
}
