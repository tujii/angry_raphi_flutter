import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('AuthEvent', () {
    final testDate = DateTime(2024, 1);
    final testUser = UserEntity(
      id: 'user123',
      email: 'test@example.com',
      displayName: 'Test User',
      isAdmin: false,
      createdAt: testDate,
    );

    test('AuthStarted has empty props', () {
      final event = AuthStarted();
      expect(event.props, isEmpty);
    });

    test('AuthSignInRequested has empty props', () {
      final event = AuthSignInRequested();
      expect(event.props, isEmpty);
    });

    test('AuthSignOutRequested has empty props', () {
      final event = AuthSignOutRequested();
      expect(event.props, isEmpty);
    });

    test('AuthUserChanged includes user in props', () {
      final event = AuthUserChanged(testUser);
      expect(event.user, equals(testUser));
      expect(event.props, equals([testUser]));
    });

    test('AuthUserChanged can have null user', () {
      final event = AuthUserChanged(null);
      expect(event.user, isNull);
      expect(event.props, equals([null]));
    });

    test('two AuthUserChanged with same user are equal', () {
      final event1 = AuthUserChanged(testUser);
      final event2 = AuthUserChanged(testUser);
      expect(event1, equals(event2));
    });

    test('two AuthUserChanged with null are equal', () {
      final event1 = AuthUserChanged(null);
      final event2 = AuthUserChanged(null);
      expect(event1, equals(event2));
    });

    test('AuthUserChanged with different users are not equal', () {
      final user2 = UserEntity(
        id: 'user456',
        email: 'other@example.com',
        displayName: 'Other User',
        isAdmin: true,
        createdAt: testDate,
      );

      final event1 = AuthUserChanged(testUser);
      final event2 = AuthUserChanged(user2);
      expect(event1, isNot(equals(event2)));
    });

    test('AuthUserChanged with user and null are not equal', () {
      final event1 = AuthUserChanged(testUser);
      final event2 = AuthUserChanged(null);
      expect(event1, isNot(equals(event2)));
    });

    test('different event types are not equal', () {
      final started = AuthStarted();
      final signIn = AuthSignInRequested();
      final signOut = AuthSignOutRequested();
      final userChanged = AuthUserChanged(testUser);

      expect(started, isNot(equals(signIn)));
      expect(started, isNot(equals(signOut)));
      expect(started, isNot(equals(userChanged)));
      expect(signIn, isNot(equals(signOut)));
    });
  });
}
