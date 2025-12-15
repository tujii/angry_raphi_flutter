import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';

void main() {
  group('User', () {
    final testDate = DateTime(2024, 1, 1);
    const testLastRaphconDate = DateTime(2024, 1, 15);

    test('creates user with required fields', () {
      const user = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      expect(user.id, equals('1'));
      expect(user.initials, equals('JD'));
      expect(user.raphconCount, equals(5));
      expect(user.createdAt, equals(testDate));
      expect(user.avatarUrl, isNull);
      expect(user.lastRaphconAt, isNull);
      expect(user.isActive, isTrue);
    });

    test('creates user with all fields', () {
      final user = User(
        id: '1',
        initials: 'JD',
        avatarUrl: 'https://example.com/avatar.jpg',
        raphconCount: 10,
        createdAt: testDate,
        lastRaphconAt: testLastRaphconDate,
        isActive: false,
      );

      expect(user.id, equals('1'));
      expect(user.initials, equals('JD'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.raphconCount, equals(10));
      expect(user.createdAt, equals(testDate));
      expect(user.lastRaphconAt, equals(testLastRaphconDate));
      expect(user.isActive, isFalse);
    });

    test('name getter returns initials', () {
      const user = User(
        id: '1',
        initials: 'AB',
        raphconCount: 0,
        createdAt: testDate,
      );

      expect(user.name, equals('AB'));
    });

    test('copyWith creates new user with updated fields', () {
      const user = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      final updated = user.copyWith(raphconCount: 10, isActive: false);

      expect(updated.id, equals('1'));
      expect(updated.initials, equals('JD'));
      expect(updated.raphconCount, equals(10));
      expect(updated.isActive, isFalse);
      expect(updated.createdAt, equals(testDate));
    });

    test('copyWith with no parameters returns same values', () {
      const user = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      final copy = user.copyWith();

      expect(copy.id, equals(user.id));
      expect(copy.initials, equals(user.initials));
      expect(copy.raphconCount, equals(user.raphconCount));
      expect(copy.isActive, equals(user.isActive));
    });

    test('equality works correctly', () {
      const user1 = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      const user2 = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('equality returns false for different users', () {
      const user1 = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      const user2 = User(
        id: '2',
        initials: 'AB',
        raphconCount: 3,
        createdAt: testDate,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('toString returns formatted string', () {
      const user = User(
        id: '1',
        initials: 'JD',
        raphconCount: 5,
        createdAt: testDate,
      );

      final str = user.toString();
      expect(str, contains('User('));
      expect(str, contains('id: 1'));
      expect(str, contains('initials: JD'));
      expect(str, contains('raphconCount: 5'));
    });
  });
}
