import '../../features/user/domain/entities/user.dart';

/// Utility class for ranking calculations.
/// Uses standard competition ranking where tied users get the same rank.
class RankingUtils {
  /// Calculates the rank of a user at a given index, accounting for ties.
  /// Users with the same raphconCount get the same rank.
  /// Returns a 1-based rank (1 = Gold, 2 = Silver, 3 = Bronze).
  ///
  /// Uses standard competition ranking:
  /// - [10, 10, 5] → ranks [1, 1, 3]
  /// - [10, 8, 5] → ranks [1, 2, 3]
  /// - [10, 10, 10] → ranks [1, 1, 1]
  static int calculateRank(List<User> userList, int index) {
    if (index < 0 || index >= userList.length) {
      throw RangeError.index(index, userList, 'index', 'Index out of bounds');
    }
    
    if (index == 0) return 1;

    int rank = 1;
    for (int i = 0; i < index; i++) {
      // Only increment rank when raphconCount changes
      if (userList[i].raphconCount != userList[i + 1].raphconCount) {
        rank = i + 2; // +2 because rank is 1-based and we're at i+1 position
      }
    }
    return rank;
  }
}
