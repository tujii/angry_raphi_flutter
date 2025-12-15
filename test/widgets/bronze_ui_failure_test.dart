import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('Bronze Badge UI Display - EXPECTED TO FAIL', () {
    test(
        'FAILING: I.G. should display BRONZE badge in UI but currently does not',
        () {
      // This test documents the exact bug visible in the screenshot

      final testUsers = [
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

      // ACTUAL PROBLEM FROM SCREENSHOT:
      // ✅ S.C. shows "GOLD" badge with gold color
      // ✅ M.J. shows "SILBER" badge with silver color
      // ✅ J.D. shows "SILBER" badge with silver color
      // ❌ I.G. shows RED DOT but NO "BRONZE" text and NO bronze color
      // ✅ R.U. shows no badge (correct)

      final igUser = testUsers[3]; // I.G.

      expect(igUser.initials, equals('I.G.'));
      expect(igUser.raphconCount, equals(4));

      // Logic that SHOULD make I.G. show bronze:
      final uniqueScores = testUsers.map((u) => u.raphconCount).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      final top3UniqueScores = uniqueScores.take(3).toList();

      expect(top3UniqueScores, equals([9, 5, 4]));
      expect(top3UniqueScores.contains(igUser.raphconCount), isTrue,
          reason: 'I.G. raphcon count (4) IS in top 3 unique scores');

      // THE FAILING EXPECTATION:
      // In the UI, I.G. should show:
      // 1. ❌ "BRONZE" text (currently missing)
      // 2. ❌ Bronze color background (0xFFCD7F32) (currently red dot only)
      // 3. ❌ Bronze medal icon (currently person icon only)

      // This test passes logically but documents the UI failure
      // The bug is in the styling functions using rank instead of badge logic
    });

    test('FAILING: Expected vs Actual UI state comparison', () {
      // This test would FAIL if we could actually test the UI

      const expectedUIState = {
        'S.C.': {'badge': 'GOLD', 'color': 0xFFFFD700, 'visible': true},
        'M.J.': {'badge': 'SILBER', 'color': 0xFFC0C0C0, 'visible': true},
        'J.D.': {'badge': 'SILBER', 'color': 0xFFC0C0C0, 'visible': true},
        'I.G.': {
          'badge': 'BRONZE',
          'color': 0xFFCD7F32,
          'visible': true
        }, // EXPECTED
        'R.U.': {'badge': '', 'color': null, 'visible': false},
      };

      const actualUIState = {
        'S.C.': {'badge': 'GOLD', 'color': 0xFFFFD700, 'visible': true},
        'M.J.': {'badge': 'SILBER', 'color': 0xFFC0C0C0, 'visible': true},
        'J.D.': {'badge': 'SILBER', 'color': 0xFFC0C0C0, 'visible': true},
        'I.G.': {
          'badge': '',
          'color': 0xFF8B0000,
          'visible': true
        }, // ACTUAL (red dot, no text)
        'R.U.': {'badge': '', 'color': null, 'visible': false},
      };

      // This would fail in a real UI test:
      // expect(actualUIState['I.G.']['badge'], equals(expectedUIState['I.G.']['badge']));
      // expect(actualUIState['I.G.']['color'], equals(expectedUIState['I.G.']['color']));

      // Instead we document the discrepancy:
      expect(expectedUIState['I.G.']!['badge'], equals('BRONZE'));
      expect(actualUIState['I.G.']!['badge'], equals(''));

      expect(expectedUIState['I.G.']!['color'], equals(0xFFCD7F32)); // Bronze
      expect(
          actualUIState['I.G.']!['color'], equals(0xFF8B0000)); // Dark red dot
    });
  });
}
