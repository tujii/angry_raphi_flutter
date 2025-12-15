import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:angry_raphi/core/utils/ranking_utils.dart';

void main() {
  group('Bronze Badge BUG - FAILING TESTS', () {
    late List<User> testUsers;

    setUp(() {
      // Exact same users from screenshot
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

    // Simulate the current _shouldShowBadge logic
    bool shouldShowBadge(List<User> userList, int index) {
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

    // Simulate the current rank-based badge styling
    String getRankTextByRank(int rank) {
      switch (rank) {
        case 1:
          return 'GOLD';
        case 2:
          return 'SILVER';
        case 3:
          return 'BRONZE';
        default:
          return '';
      }
    }

    test('BUG IDENTIFIED: I.G. gets badge indicator but wrong rank styling',
        () {
      // I.G. is at index 3
      const igIndex = 3;
      final igRank = RankingUtils.calculateRank(testUsers, igIndex);

      // Badge logic says I.G. should get a badge
      expect(shouldShowBadge(testUsers, igIndex), isTrue,
          reason: 'I.G. should get badge (4 is in top 3 unique scores)');

      // But rank is 4, not 3, so styling functions return nothing!
      expect(igRank, equals(4),
          reason: 'I.G. gets rank 4 due to tied positions');

      expect(getRankTextByRank(igRank), equals(''),
          reason: 'BRONZE text not shown because rank=4, not rank=3!');

      // This is the bug: Badge shows (red dot) but no styling (bronze color/text)
    });

    test('FAILING EXPECTATION: I.G. should show BRONZE despite rank=4', () {
      const igIndex = 3;
      final igRank = RankingUtils.calculateRank(testUsers, igIndex);
      final shouldHaveBadge = shouldShowBadge(testUsers, igIndex);

      // THE BUG: shouldShowBadge=true but getRankText='' because rank=4
      expect(shouldHaveBadge, isTrue);
      expect(igRank, equals(4)); // This causes the styling problem

      // This test shows the disconnect between badge logic and styling logic
      // Badge logic: Uses unique scores (correct) ✓
      // Styling logic: Uses rank position (wrong for ties) ❌
    });

    test(
        'SOLUTION NEEDED: Badge styling should use badge logic, not rank logic',
        () {
      // Current broken flow:
      // 1. shouldShowBadge(I.G.) = true ✓ (shows red dot indicator)
      // 2. rank = 4 ❌ (due to ties)
      // 3. getRankText(4) = '' ❌ (no BRONZE text)
      // 4. getRankColor(4) = primary color ❌ (no bronze color)

      // Correct flow should be:
      // 1. shouldShowBadge(I.G.) = true ✓
      // 2. badgeType = getBadgeTypeByUniqueScore(I.G.) = 'BRONZE' ✓
      // 3. show bronze styling ✓

      final uniqueScores = testUsers.map((u) => u.raphconCount).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      final igScore = testUsers[3].raphconCount; // 4
      final scorePosition =
          uniqueScores.indexOf(igScore) + 1; // Position in unique scores

      expect(uniqueScores, equals([9, 5, 4, 3]));
      expect(scorePosition, equals(3),
          reason: 'I.G. score (4) is 3rd in unique scores = BRONZE position');

      // This is what the styling should use: scorePosition (3) not rank (4)
    });
  });
}
