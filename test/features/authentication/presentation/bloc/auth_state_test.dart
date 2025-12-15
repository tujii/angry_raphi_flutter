import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('AuthState', () {
    final testDate = DateTime(2024, 1);
    final testUser = UserEntity(
      id: 'user123',
      email: 'test@example.com',
      displayName: 'Test User',
      isAdmin: false,
      createdAt: testDate,
    );

    test('AuthInitial has empty props', () {
      final state = AuthInitial();
      expect(state.props, isEmpty);
    });

    test('AuthLoading has empty props', () {
      final state = AuthLoading();
      expect(state.props, isEmpty);
    });

    test('AuthAuthenticated includes user in props', () {
      final state = AuthAuthenticated(testUser);
      expect(state.user, equals(testUser));
      expect(state.props, equals([testUser]));
    });

    test('AuthUnauthenticated has empty props', () {
      final state = AuthUnauthenticated();
      expect(state.props, isEmpty);
    });

    test('AuthError includes message in props', () {
      const message = 'Authentication failed';
      final state = AuthError(message);
      expect(state.message, equals(message));
      expect(state.props, equals([message]));
    });

    test('two AuthAuthenticated with same user are equal', () {
      final state1 = AuthAuthenticated(testUser);
      final state2 = AuthAuthenticated(testUser);
      expect(state1, equals(state2));
    });

    test('two AuthError with same message are equal', () {
      const message = 'Error';
      final state1 = AuthError(message);
      final state2 = AuthError(message);
      expect(state1, equals(state2));
    });

    test('AuthError with different messages are not equal', () {
      final state1 = AuthError('Error 1');
      final state2 = AuthError('Error 2');
      expect(state1, isNot(equals(state2)));
    });

    test('different state types are not equal', () {
      final initial = AuthInitial();
      final loading = AuthLoading();
      final authenticated = AuthAuthenticated(testUser);
      final unauthenticated = AuthUnauthenticated();
      final error = AuthError('Error');

      expect(initial, isNot(equals(loading)));
      expect(initial, isNot(equals(authenticated)));
      expect(initial, isNot(equals(unauthenticated)));
      expect(initial, isNot(equals(error)));
    });
  });
}
