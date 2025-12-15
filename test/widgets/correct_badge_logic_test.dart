import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper function to simulate the badge logic
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

void main() {
  group('Correct Badge Logic Tests', () {
    late List<User> testUsers;

    setUp(() {
      testUsers = [
        User(
            id: '1',
            initials: 'S.C.',
            raphconCount: 9,
            createdAt: DateTime.now()),
        User(
            id: '2',
            initials: 'M.J.',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '3',
            initials: 'J.D.',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '4',
            initials: 'I.G.',
            raphconCount: 4,
            createdAt: DateTime.now()),
        User(
            id: '5',
            initials: 'R.U.',
            raphconCount: 3,
            createdAt: DateTime.now()),
      ];
    });

    test('should show correct badges: 1 Gold, 2 Silver, 1 Bronze', () {
      // Unique scores: [9, 5, 4] - top 3 unique values
      // Expected badges:
      // S.C. (9) -> Gold ✓
      // M.J. (5) -> Silver ✓
      // J.D. (5) -> Silver ✓ (same score as M.J.)
      // I.G. (4) -> Bronze ✓ (3rd unique score)
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

      // All have same score, all should get badges (Gold for all)
      expect(shouldShowBadge(allSameUsers, 0), isTrue);
      expect(shouldShowBadge(allSameUsers, 1), isTrue);
      expect(shouldShowBadge(allSameUsers, 2), isTrue);
    });

    test('should work with exactly 3 unique scores', () {
      final exactlyThreeUsers = [
        User(
            id: '1',
            initials: 'A.A.',
            raphconCount: 10,
            createdAt: DateTime.now()),
        User(
            id: '2',
            initials: 'B.B.',
            raphconCount: 8,
            createdAt: DateTime.now()),
        User(
            id: '3',
            initials: 'C.C.',
            raphconCount: 6,
            createdAt: DateTime.now()),
        User(
            id: '4',
            initials: 'D.D.',
            raphconCount: 4,
            createdAt: DateTime.now()),
      ];

      expect(shouldShowBadge(exactlyThreeUsers, 0), isTrue); // Gold (10)
      expect(shouldShowBadge(exactlyThreeUsers, 1), isTrue); // Silver (8)
      expect(shouldShowBadge(exactlyThreeUsers, 2), isTrue); // Bronze (6)
      expect(shouldShowBadge(exactlyThreeUsers, 3), isFalse); // No badge (4)
    });
  });
}
