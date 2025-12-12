import 'package:injectable/injectable.dart';

import '../features/raphcon_management/domain/repositories/raphcons_repository.dart';

@injectable
class RaphconExpiryService {
  final RaphconsRepository raphconRepository;

  RaphconExpiryService({required this.raphconRepository});

  /// Check and expire Raphcons older than one year
  /// Returns the number of expired Raphcons
  Future<int> checkAndExpireOldRaphcons() async {
    try {
      final result = await raphconRepository.expireOldRaphcons();
      return result.fold(
        (failure) {
          // Log error but don't throw - silent fail
          return 0;
        },
        (count) => count,
      );
    } catch (e) {
      // Silent fail - don't interrupt user experience
      return 0;
    }
  }
}
