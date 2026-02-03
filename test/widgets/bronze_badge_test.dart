import 'package:angry_raphi/core/utils/ranking_utils.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bronze Badge Display Logic Tests', () {
    late List<User> testUsers;

    setUp(() {
      testUsers = [
        User(
          id: '1',
          initials: 'S.C.',
          raphconCount: 9,
          createdAt: DateTime.now(),
        ),
        User(
          id: '2',
          initials: 'M.J.',
          raphconCount: 5,
          createdAt: DateTime.now(),
        ),
        User(
          id: '3',
          initials: 'J.D.',
          raphconCount: 5,
          createdAt: DateTime.now(),
        ),
        User(
          id: '4',
          initials: 'I.G.',
          raphconCount: 4,
          createdAt: DateTime.now(),
        ),
        User(
          id: '5',
          initials: 'R.U.',
          raphconCount: 3,
          createdAt: DateTime.now(),
        ),
      ];
    });

    test('should calculate correct ranks with tied positions', () {
      // Test ranking logic: [9, 5, 5, 4, 3] should become [1, 2, 2, 4, 5]
      expect(
          RankingUtils.calculateRank(testUsers, 0), equals(1)); // S.C. - Gold
      expect(
          RankingUtils.calculateRank(testUsers, 1), equals(2)); // M.J. - Silver
      expect(RankingUtils.calculateRank(testUsers, 2),
          equals(2)); // J.D. - Silver (tied)
      expect(RankingUtils.calculateRank(testUsers, 3),
          equals(4)); // I.G. - Rank 4 (should NOT show bronze)
      expect(
          RankingUtils.calculateRank(testUsers, 4), equals(5)); // R.U. - Rank 5
    });

    test('bronze badge should only show for rank 3 or better', () {
      // According to the current logic, bronze badge only shows for rank <= 3
      // But with tied positions [1, 2, 2, 4, 5], nobody gets rank 3
      // This explains why Bronze is not shown!

      final ranks = [
        RankingUtils.calculateRank(testUsers, 0), // 1
        RankingUtils.calculateRank(testUsers, 1), // 2
        RankingUtils.calculateRank(testUsers, 2), // 2
        RankingUtils.calculateRank(testUsers, 3), // 4
        RankingUtils.calculateRank(testUsers, 4), // 5
      ];

      // Count how many users have rank <= 3
      final bronzeCandidates = ranks.where((rank) => rank <= 3).length;

      // With ties at rank 2, nobody gets rank 3, so no bronze badge!
      expect(bronzeCandidates, equals(3)); // Only ranks 1, 2, 2 - no rank 3!
      expect(ranks.contains(3), isFalse); // No user has exactly rank 3
    });

    test('bronze should appear with different user distribution', () {
      // Test with users that would create a rank 3
      final differentUsers = [
        User(
            id: '1',
            initials: 'A.B.',
            raphconCount: 10,
            createdAt: DateTime.now()),
        User(
            id: '2',
            initials: 'C.D.',
            raphconCount: 8,
            createdAt: DateTime.now()),
        User(
            id: '3',
            initials: 'E.F.',
            raphconCount: 6,
            createdAt: DateTime.now()),
        User(
            id: '4',
            initials: 'G.H.',
            raphconCount: 4,
            createdAt: DateTime.now()),
      ];

      expect(RankingUtils.calculateRank(differentUsers, 0), equals(1)); // Gold
      expect(
          RankingUtils.calculateRank(differentUsers, 1), equals(2)); // Silver
      expect(RankingUtils.calculateRank(differentUsers, 2),
          equals(3)); // Bronze - THIS would show!
      expect(
          RankingUtils.calculateRank(differentUsers, 3), equals(4)); // No badge
    });
  });
}
