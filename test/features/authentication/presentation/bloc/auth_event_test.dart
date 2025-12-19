import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('AuthEvent', () {
    final testDate = DateTime(2024, 1, 1);
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

    test('AuthPhoneSignInRequested includes phoneNumber in props', () {
      const phoneNumber = '+491234567890';
      final event = AuthPhoneSignInRequested(phoneNumber);
      expect(event.phoneNumber, equals(phoneNumber));
      expect(event.props, equals([phoneNumber]));
    });

    test('two AuthPhoneSignInRequested with same phoneNumber are equal', () {
      const phoneNumber = '+491234567890';
      final event1 = AuthPhoneSignInRequested(phoneNumber);
      final event2 = AuthPhoneSignInRequested(phoneNumber);
      expect(event1, equals(event2));
    });

    test('AuthPhoneSignInRequested with different phoneNumbers are not equal', () {
      final event1 = AuthPhoneSignInRequested('+491234567890');
      final event2 = AuthPhoneSignInRequested('+491234567891');
      expect(event1, isNot(equals(event2)));
    });

    test('AuthVerifyPhoneCode includes verificationId and smsCode in props', () {
      const verificationId = 'verification123';
      const smsCode = '123456';
      final event = AuthVerifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      expect(event.verificationId, equals(verificationId));
      expect(event.smsCode, equals(smsCode));
      expect(event.props, equals([verificationId, smsCode]));
    });

    test('two AuthVerifyPhoneCode with same values are equal', () {
      const verificationId = 'verification123';
      const smsCode = '123456';
      final event1 = AuthVerifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final event2 = AuthVerifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      expect(event1, equals(event2));
    });

    test('AuthVerifyPhoneCode with different values are not equal', () {
      final event1 = AuthVerifyPhoneCode(
        verificationId: 'verification123',
        smsCode: '123456',
      );
      final event2 = AuthVerifyPhoneCode(
        verificationId: 'verification456',
        smsCode: '654321',
      );
      expect(event1, isNot(equals(event2)));
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
