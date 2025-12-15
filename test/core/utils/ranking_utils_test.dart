import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/utils/ranking_utils.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('RankingUtils.calculateRank', () {
    // Helper function to create a user with a specific raphconCount
    User createUser(int raphconCount, {String id = '1'}) {
      return User(
        id: id,
        initials: 'U$id',
        raphconCount: raphconCount,
        createdAt: DateTime.now(),
      );
    }

    test('returns rank 1 for first user', () {
      final users = [createUser(10)];
      expect(RankingUtils.calculateRank(users, 0), equals(1));
    });

    test('returns correct ranks when all users have different counts', () {
      final users = [
        createUser(10), // rank 1
        createUser(8, id: '2'),  // rank 2
        createUser(5, id: '3'),  // rank 3
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(2));
      expect(RankingUtils.calculateRank(users, 2), equals(3));
    });

    test('returns same rank for users with same count (two tied for first)', () {
      // [10, 10, 5] → ranks [1, 1, 3] (standard competition ranking)
      final users = [
        createUser(10), // rank 1
        createUser(10, id: '2'), // rank 1 (tied)
        createUser(5, id: '3'),  // rank 3 (skips rank 2)
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(1));
      expect(RankingUtils.calculateRank(users, 2), equals(3));
    });

    test('returns same rank for users with same count (two tied for second)', () {
      // [10, 8, 8, 5] → ranks [1, 2, 2, 4]
      final users = [
        createUser(10), // rank 1
        createUser(8, id: '2'),  // rank 2
        createUser(8, id: '3'),  // rank 2 (tied)
        createUser(5, id: '4'),  // rank 4 (skips rank 3)
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(2));
      expect(RankingUtils.calculateRank(users, 2), equals(2));
      expect(RankingUtils.calculateRank(users, 3), equals(4));
    });

    test('returns rank 1 for all users when all have same count', () {
      // [10, 10, 10] → ranks [1, 1, 1]
      final users = [
        createUser(10), // rank 1
        createUser(10, id: '2'), // rank 1
        createUser(10, id: '3'), // rank 1
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(1));
      expect(RankingUtils.calculateRank(users, 2), equals(1));
    });

    test('handles three users tied for first place followed by another', () {
      // [10, 10, 10, 5] → ranks [1, 1, 1, 4]
      final users = [
        createUser(10), // rank 1
        createUser(10, id: '2'), // rank 1
        createUser(10, id: '3'), // rank 1
        createUser(5, id: '4'),  // rank 4
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(1));
      expect(RankingUtils.calculateRank(users, 2), equals(1));
      expect(RankingUtils.calculateRank(users, 3), equals(4));
    });

    test('handles single user list', () {
      final users = [createUser(10)];
      expect(RankingUtils.calculateRank(users, 0), equals(1));
    });

    test('handles users with zero raphcon count', () {
      final users = [
        createUser(5),  // rank 1
        createUser(0, id: '2'),  // rank 2
        createUser(0, id: '3'),  // rank 2
      ];

      expect(RankingUtils.calculateRank(users, 0), equals(1));
      expect(RankingUtils.calculateRank(users, 1), equals(2));
      expect(RankingUtils.calculateRank(users, 2), equals(2));
    });

    test('throws RangeError for negative index', () {
      final users = [createUser(10)];
      expect(
        () => RankingUtils.calculateRank(users, -1),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws RangeError for index out of bounds', () {
      final users = [createUser(10)];
      expect(
        () => RankingUtils.calculateRank(users, 1),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws RangeError for empty list', () {
      final List<User> users = [];
      expect(
        () => RankingUtils.calculateRank(users, 0),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
