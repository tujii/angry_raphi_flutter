import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('Complex Badge Distribution Test', () {
    late List<User> testUsers;

    setUp(() {
      // Create test scenario: 2 Gold, 4 Silver, 10 Bronze
      testUsers = [
        // 2 Gold users (15 Raphcons each)
        User(
            id: '1',
            initials: 'G1',
            raphconCount: 15,
            createdAt: DateTime.now()),
        User(
            id: '2',
            initials: 'G2',
            raphconCount: 15,
            createdAt: DateTime.now()),

        // 4 Silver users (10 Raphcons each)
        User(
            id: '3',
            initials: 'S1',
            raphconCount: 10,
            createdAt: DateTime.now()),
        User(
            id: '4',
            initials: 'S2',
            raphconCount: 10,
            createdAt: DateTime.now()),
        User(
            id: '5',
            initials: 'S3',
            raphconCount: 10,
            createdAt: DateTime.now()),
        User(
            id: '6',
            initials: 'S4',
            raphconCount: 10,
            createdAt: DateTime.now()),

        // 10 Bronze users (7 Raphcons each)
        User(
            id: '7',
            initials: 'B1',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '8',
            initials: 'B2',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '9',
            initials: 'B3',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '10',
            initials: 'B4',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '11',
            initials: 'B5',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '12',
            initials: 'B6',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '13',
            initials: 'B7',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '14',
            initials: 'B8',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '15',
            initials: 'B9',
            raphconCount: 7,
            createdAt: DateTime.now()),
        User(
            id: '16',
            initials: 'B10',
            raphconCount: 7,
            createdAt: DateTime.now()),

        // 5 users without badges (5 Raphcons each)
        User(
            id: '17',
            initials: 'N1',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '18',
            initials: 'N2',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '19',
            initials: 'N3',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '20',
            initials: 'N4',
            raphconCount: 5,
            createdAt: DateTime.now()),
        User(
            id: '21',
            initials: 'N5',
            raphconCount: 5,
            createdAt: DateTime.now()),
      ];
    });

    // Helper functions simulating the badge logic
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

    test('should have correct unique score distribution', () {
      final uniqueScores = testUsers.map((u) => u.raphconCount).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      // Should have 4 unique scores: [15, 10, 7, 5]
      expect(uniqueScores, equals([15, 10, 7, 5]));

      final top3UniqueScores = uniqueScores.take(3).toList();
      expect(top3UniqueScores, equals([15, 10, 7]));

      print('Unique scores: $uniqueScores');
      print('Top 3 for badges: $top3UniqueScores');
    });

    test('should distribute badges correctly: 2 Gold, 4 Silver, 10 Bronze', () {
      int goldCount = 0;
      int silverCount = 0;
      int bronzeCount = 0;
      int noBadgeCount = 0;

      for (int i = 0; i < testUsers.length; i++) {
        final hasBadge = shouldShowBadge(testUsers, i);

        if (hasBadge) {
          final badgePosition = getBadgePosition(testUsers, i);
          final badgeText = getBadgeText(badgePosition);

          switch (badgeText) {
            case 'GOLD':
              goldCount++;
              break;
            case 'SILVER':
              silverCount++;
              break;
            case 'BRONZE':
              bronzeCount++;
              break;
          }

          print(
              '${testUsers[i].initials} (${testUsers[i].raphconCount}) → $badgeText');
        } else {
          noBadgeCount++;
          print(
              '${testUsers[i].initials} (${testUsers[i].raphconCount}) → NO BADGE');
        }
      }

      // Verify the exact distribution
      expect(goldCount, equals(2), reason: 'Should have exactly 2 Gold badges');
      expect(silverCount, equals(4),
          reason: 'Should have exactly 4 Silver badges');
      expect(bronzeCount, equals(10),
          reason: 'Should have exactly 10 Bronze badges');
      expect(noBadgeCount, equals(5),
          reason: 'Should have exactly 5 users without badges');

      print('\n=== BADGE DISTRIBUTION SUMMARY ===');
      print('🥇 Gold: $goldCount users');
      print('🥈 Silver: $silverCount users');
      print('🥉 Bronze: $bronzeCount users');
      print('❌ No Badge: $noBadgeCount users');
      print('Total: ${testUsers.length} users');
    });

    test('should assign badges based on unique scores, not positions', () {
      // All users with 15 Raphcons should get Gold (positions 0-1)
      expect(shouldShowBadge(testUsers, 0), isTrue);
      expect(getBadgeText(getBadgePosition(testUsers, 0)), equals('GOLD'));
      expect(shouldShowBadge(testUsers, 1), isTrue);
      expect(getBadgeText(getBadgePosition(testUsers, 1)), equals('GOLD'));

      // All users with 10 Raphcons should get Silver (positions 2-5)
      for (int i = 2; i <= 5; i++) {
        expect(shouldShowBadge(testUsers, i), isTrue,
            reason: 'User at position $i should get badge');
        expect(getBadgeText(getBadgePosition(testUsers, i)), equals('SILVER'),
            reason: 'User at position $i should get SILVER badge');
      }

      // All users with 7 Raphcons should get Bronze (positions 6-15)
      for (int i = 6; i <= 15; i++) {
        expect(shouldShowBadge(testUsers, i), isTrue,
            reason: 'User at position $i should get badge');
        expect(getBadgeText(getBadgePosition(testUsers, i)), equals('BRONZE'),
            reason: 'User at position $i should get BRONZE badge');
      }

      // Users with 5 Raphcons should NOT get badges (positions 16-20)
      for (int i = 16; i < testUsers.length; i++) {
        expect(shouldShowBadge(testUsers, i), isFalse,
            reason: 'User at position $i should NOT get badge');
      }
    });

    test('should handle large tie scenarios correctly', () {
      // This tests the edge case of many users having the same score

      final usersByScore = <int, List<User>>{};
      for (final user in testUsers) {
        usersByScore.putIfAbsent(user.raphconCount, () => []).add(user);
      }

      expect(usersByScore[15]!.length, equals(2),
          reason: '2 users with 15 Raphcons');
      expect(usersByScore[10]!.length, equals(4),
          reason: '4 users with 10 Raphcons');
      expect(usersByScore[7]!.length, equals(10),
          reason: '10 users with 7 Raphcons');
      expect(usersByScore[5]!.length, equals(5),
          reason: '5 users with 5 Raphcons');

      // All users with the same score should get the same badge type
      final goldUsers = usersByScore[15]!;
      final silverUsers = usersByScore[10]!;
      final bronzeUsers = usersByScore[7]!;
      final noBadgeUsers = usersByScore[5]!;

      // Verify all gold users get gold
      for (final user in goldUsers) {
        final index = testUsers.indexOf(user);
        expect(
            getBadgeText(getBadgePosition(testUsers, index)), equals('GOLD'));
      }

      // Verify all silver users get silver
      for (final user in silverUsers) {
        final index = testUsers.indexOf(user);
        expect(
            getBadgeText(getBadgePosition(testUsers, index)), equals('SILVER'));
      }

      // Verify all bronze users get bronze
      for (final user in bronzeUsers) {
        final index = testUsers.indexOf(user);
        expect(
            getBadgeText(getBadgePosition(testUsers, index)), equals('BRONZE'));
      }

      // Verify no-badge users don't get badges
      for (final user in noBadgeUsers) {
        final index = testUsers.indexOf(user);
        expect(shouldShowBadge(testUsers, index), isFalse);
      }
    });
  });
}
