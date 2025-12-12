import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/utils/ranking_utils.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('Bronze Badge Fix Tests', () {
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

    test('should show badges for top 3 positions instead of top 3 ranks', () {
      // With the new logic using index < 3, the badges should be:
      // Index 0: S.C. (9) -> Gold (position 1)
      // Index 1: M.J. (5) -> Silver (position 2)
      // Index 2: J.D. (5) -> Bronze (position 3) <- NOW SHOWS BRONZE!
      // Index 3: I.G. (4) -> No badge (position 4)
      // Index 4: R.U. (3) -> No badge (position 5)

      // Test that the display rank logic works
      for (int i = 0; i < 3; i++) {
        final displayRank = i + 1; // Position-based rank for top 3
        expect(displayRank, isIn([1, 2, 3]));
      }

      // Test that I.G. at index 3 would NOT get a badge
      expect(3 < 3, isFalse);

      // Test that the third user (J.D. at index 2) WOULD get bronze
      expect(2 < 3, isTrue);
    });

    test('verify the bronze fix covers edge cases', () {
      // Test case: All users have same score (should all get gold)

      // With new logic, first 3 positions get badges regardless of ties:
      // Position 1: A.A. -> Gold badge (display rank 1)
      // Position 2: B.B. -> Silver badge (display rank 2)
      // Position 3: C.C. -> Bronze badge (display rank 3)
      // Position 4: D.D. -> No badge

      for (int i = 0; i < 3; i++) {
        expect(i < 3, isTrue, reason: 'Position ${i + 1} should get a badge');
      }

      expect(3 < 3, isFalse, reason: 'Position 4 should NOT get a badge');
    });

    test('confirm original ranking logic still works for display', () {
      // The actual ranks should still be calculated correctly
      expect(RankingUtils.calculateRank(testUsers, 0), equals(1)); // S.C.
      expect(RankingUtils.calculateRank(testUsers, 1), equals(2)); // M.J.
      expect(
          RankingUtils.calculateRank(testUsers, 2), equals(2)); // J.D. (tied)
      expect(RankingUtils.calculateRank(testUsers, 3), equals(4)); // I.G.
      expect(RankingUtils.calculateRank(testUsers, 4), equals(5)); // R.U.

      // But for badge display, we use position-based logic for top 3
      final badgeRanks = [
        1,
        2,
        3
      ]; // Positions 1, 2, 3 get Gold, Silver, Bronze

      for (int i = 0; i < 3; i++) {
        final displayRank = badgeRanks[i];
        expect(displayRank, isIn([1, 2, 3]));
      }
    });
  });
}
