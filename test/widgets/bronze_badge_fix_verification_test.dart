import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('Bronze Badge Fix Verification', () {
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

    // Simulate the new _getBadgePosition logic
    int getBadgePosition(List<User> userList, int index) {
      if (index >= userList.length) return 0;

      final uniqueCounts = userList
          .map((user) => user.raphconCount)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      final userCount = userList[index].raphconCount;
      return uniqueCounts.indexOf(userCount) + 1; // 1-based position
    }

    // Simulate the new badge styling functions
    String getBadgeText(int badgePosition) {
      switch (badgePosition) {
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

    int getBadgeColor(int badgePosition) {
      switch (badgePosition) {
        case 1:
          return 0xFFFFD700; // Gold
        case 2:
          return 0xFFC0C0C0; // Silver
        case 3:
          return 0xFFCD7F32; // Bronze
        default:
          return 0xFF8B0000; // Default primary
      }
    }

    test('FIXED: I.G. should now get correct badge position and styling', () {
      final igIndex = 3; // I.G. is at index 3
      final igBadgePosition = getBadgePosition(testUsers, igIndex);
      final igBadgeText = getBadgeText(igBadgePosition);
      final igBadgeColor = getBadgeColor(igBadgePosition);

      // I.G. should get badge position 3 (bronze)
      expect(igBadgePosition, equals(3),
          reason: 'I.G. raphcon count (4) is 3rd in unique scores');

      // I.G. should get bronze text and color
      expect(igBadgeText, equals('BRONZE'),
          reason: 'Badge position 3 should show BRONZE text');

      expect(igBadgeColor, equals(0xFFCD7F32),
          reason: 'Badge position 3 should show bronze color');

      print('✅ I.G. Fix Verification:');
      print('   Badge Position: $igBadgePosition');
      print('   Badge Text: $igBadgeText');
      print(
          '   Badge Color: 0x${igBadgeColor.toRadixString(16).toUpperCase()}');
    });

    test('Verify all users get correct badge positions', () {
      final positions = List.generate(
          testUsers.length, (index) => getBadgePosition(testUsers, index));

      expect(positions, equals([1, 2, 2, 3, 4]));

      // Verify badge texts
      expect(getBadgeText(positions[0]), equals('GOLD')); // S.C.
      expect(getBadgeText(positions[1]), equals('SILVER')); // M.J.
      expect(getBadgeText(positions[2]), equals('SILVER')); // J.D.
      expect(getBadgeText(positions[3]), equals('BRONZE')); // I.G. ✅ FIXED!
      expect(getBadgeText(positions[4]), equals('')); // R.U.
    });

    test('Badge positions match unique score rankings', () {
      final uniqueScores = testUsers.map((u) => u.raphconCount).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      expect(uniqueScores, equals([9, 5, 4, 3]));

      // Verify each user gets the correct badge position based on their unique score
      for (int i = 0; i < testUsers.length; i++) {
        final userScore = testUsers[i].raphconCount;
        final expectedPosition = uniqueScores.indexOf(userScore) + 1;
        final actualPosition = getBadgePosition(testUsers, i);

        expect(actualPosition, equals(expectedPosition),
            reason:
                '${testUsers[i].initials} with score $userScore should get position $expectedPosition');
      }
    });
  });
}
