import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    final testDate = DateTime(2024, 1, 1);

    test('creates user entity with required fields', () {
      final user = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: false,
        createdAt: testDate,
      );

      expect(user.id, equals('user123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, isNull);
      expect(user.isAdmin, isFalse);
      expect(user.createdAt, equals(testDate));
    });

    test('creates user entity with all fields', () {
      final user = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        isAdmin: true,
        createdAt: testDate,
      );

      expect(user.id, equals('user123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.isAdmin, isTrue);
      expect(user.createdAt, equals(testDate));
    });

    test('props returns correct list', () {
      final user = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        isAdmin: true,
        createdAt: testDate,
      );

      expect(
        user.props,
        equals([
          'user123',
          'test@example.com',
          'Test User',
          'https://example.com/photo.jpg',
          true,
          testDate,
        ]),
      );
    });

    test('equality works correctly', () {
      final user1 = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: false,
        createdAt: testDate,
      );

      final user2 = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: false,
        createdAt: testDate,
      );

      expect(user1, equals(user2));
    });

    test('equality returns false for different users', () {
      final user1 = UserEntity(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: false,
        createdAt: testDate,
      );

      final user2 = UserEntity(
        id: 'user456',
        email: 'other@example.com',
        displayName: 'Other User',
        isAdmin: true,
        createdAt: testDate,
      );

      expect(user1, isNot(equals(user2)));
    });
  });
}
