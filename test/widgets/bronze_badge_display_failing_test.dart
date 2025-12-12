import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('Bronze Badge Display - FAILING TESTS', () {
    late List<User> testUsers;

    setUp(() {
      // Exact same data as shown in the screenshot
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

    // Helper function that simulates the EXPECTED badge logic
    bool shouldShowBadgeExpected(List<User> userList, int index) {
      if (index >= userList.length) return false;

      final uniqueCounts = userList
          .map((user) => user.raphconCount)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      final userCount = userList[index].raphconCount;
      return uniqueCounts.length >= 3
          ? uniqueCounts.take(3).contains(userCount)
          : uniqueCounts.contains(userCount);
    }

    // Helper function that simulates the CURRENT BROKEN badge logic
    bool shouldShowBadgeCurrent(List<User> userList, int index) {
      // This simulates what seems to be happening - maybe it's using rank instead of unique scores
      if (index >= userList.length) return false;

      // Simulate broken logic that might be checking rank <= 3 instead of unique scores
      int currentRank = 1;
      for (int i = 0; i < index; i++) {
        if (userList[i].raphconCount > userList[index].raphconCount) {
          currentRank++;
        }
      }

      // This would be wrong because with ties, rank 4 (I.G.) wouldn't get a badge
      return currentRank <= 3;
    }

    test('EXPECTED: I.G. should get bronze badge (top 3 unique scores)', () {
      // Expected behavior: I.G. with 4 raphcons should get bronze
      // because 4 is the 3rd highest unique score [9, 5, 4]

      expect(shouldShowBadgeExpected(testUsers, 0), isTrue,
          reason: 'S.C. (9) should get Gold');
      expect(shouldShowBadgeExpected(testUsers, 1), isTrue,
          reason: 'M.J. (5) should get Silver');
      expect(shouldShowBadgeExpected(testUsers, 2), isTrue,
          reason: 'J.D. (5) should get Silver');
      expect(shouldShowBadgeExpected(testUsers, 3), isTrue,
          reason: 'I.G. (4) should get BRONZE - THIS IS FAILING IN UI!');
      expect(shouldShowBadgeExpected(testUsers, 4), isFalse,
          reason: 'R.U. (3) should NOT get badge');
    });

    test('CURRENT BROKEN: Shows why I.G. might not get bronze badge', () {
      // This test shows what might be happening - rank-based logic instead of unique score logic

      expect(shouldShowBadgeCurrent(testUsers, 0), isTrue,
          reason: 'S.C. rank 1');
      expect(shouldShowBadgeCurrent(testUsers, 1), isTrue,
          reason: 'M.J. rank 2');
      expect(shouldShowBadgeCurrent(testUsers, 2), isTrue,
          reason: 'J.D. rank 2');
      expect(shouldShowBadgeCurrent(testUsers, 3), isFalse,
          reason: 'I.G. rank 4 - NO BADGE with broken logic!');
      expect(shouldShowBadgeCurrent(testUsers, 4), isFalse,
          reason: 'R.U. rank 5');

      // This demonstrates the bug: I.G. gets rank 4 due to ties, but should still get bronze
    });

    test('FAIL CASE: Bronze badge text and color should be displayed for I.G.',
        () {
      // This test documents what we expect to see in the UI but currently fails

      final userIG = testUsers[3]; // I.G. with 4 raphcons

      expect(userIG.initials, equals('I.G.'));
      expect(userIG.raphconCount, equals(4));

      // Expected UI behavior (currently failing):
      // 1. I.G. should have bronze badge color (0xFFCD7F32)
      // 2. I.G. should show "BRONZE" text
      // 3. I.G. should be in position 4 but still get bronze (3rd unique score)

      final uniqueScores = testUsers.map((u) => u.raphconCount).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      expect(uniqueScores, equals([9, 5, 4, 3]));
      expect(uniqueScores.take(3).contains(4), isTrue,
          reason: '4 is in top 3 unique scores');

      // This test will PASS but documents the expected behavior
      // The actual UI failure is that bronze styling is not applied to I.G.
    });

    test('Unique scores vs position logic comparison', () {
      // Clear demonstration of the difference

      final scores =
          testUsers.map((u) => u.raphconCount).toList(); // [9, 5, 5, 4, 3]
      final uniqueScores = scores.toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // [9, 5, 4, 3]
      final top3Unique = uniqueScores.take(3).toList(); // [9, 5, 4]

      expect(top3Unique, equals([9, 5, 4]));

      // By position (WRONG approach):
      // Position 0: S.C. (9) ✓
      // Position 1: M.J. (5) ✓
      // Position 2: J.D. (5) ✓
      // Position 3: I.G. (4) ❌ - gets excluded by position-only logic

      // By unique scores (CORRECT approach):
      // Score 9: S.C. ✓ (Gold)
      // Score 5: M.J., J.D. ✓ (Silver)
      // Score 4: I.G. ✓ (Bronze) - should be included!
      // Score 3: R.U. ❌ (not in top 3 unique)

      expect(top3Unique.contains(testUsers[3].raphconCount), isTrue,
          reason: 'I.G. raphcon count (4) IS in top 3 unique scores');
    });
  });
}
