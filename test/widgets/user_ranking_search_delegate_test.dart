import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('UserRankingSearchDelegate Badge Logic Tests', () {
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

    // Helper function to simulate the badge logic from UserRankingSearchDelegate
    bool shouldShowBadge(List<User> userList, int index) {
      if (index >= userList.length) return false;

      // Get unique raphcon counts in descending order
      final uniqueCounts = userList
          .map((user) => user.raphconCount)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      // Show badge if user has one of the top 3 unique scores
      final userCount = userList[index].raphconCount;
      return uniqueCounts.length >= 3
          ? uniqueCounts.take(3).contains(userCount)
          : uniqueCounts.contains(userCount);
    }

    test('should show badges for correct users with tied scores', () {
      // Expected behavior:
      // S.C. (9) -> Gold badge ✓
      // M.J. (5) -> Silver badge ✓
      // J.D. (5) -> Silver badge ✓ (tied with M.J.)
      // I.G. (4) -> Bronze badge ✓ (3rd unique score)
      // R.U. (3) -> No badge (not in top 3 unique)

      expect(shouldShowBadge(testUsers, 0), isTrue,
          reason: 'S.C. should get Gold');
      expect(shouldShowBadge(testUsers, 1), isTrue,
          reason: 'M.J. should get Silver');
      expect(shouldShowBadge(testUsers, 2), isTrue,
          reason: 'J.D. should get Silver (tied)');
      expect(shouldShowBadge(testUsers, 3), isTrue,
          reason: 'I.G. should get Bronze');
      expect(shouldShowBadge(testUsers, 4), isFalse,
          reason: 'R.U. should NOT get a badge');
    });

    test('should identify unique raphcon counts correctly', () {
      final uniqueCounts = testUsers
          .map((user) => user.raphconCount)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      expect(uniqueCounts, equals([9, 5, 4, 3])); // Sorted descending
      expect(uniqueCounts.take(3).toList(), equals([9, 5, 4])); // Top 3 unique
    });

    test('should work with different score distributions', () {
      final allSameUsers = [
        User(
            id: '1',
            initials: 'A.A.',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '2',
            initials: 'B.B.',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '3',
            initials: 'C.C.',
            raphconCount: 5,
            createdAt: DateTime.now()),
      ];

      // All have same score, all should get badges
      expect(shouldShowBadge(allSameUsers, 0), isTrue);
      expect(shouldShowBadge(allSameUsers, 1), isTrue);
      expect(shouldShowBadge(allSameUsers, 2), isTrue);
    });
  });
}
