import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/errors/failures.dart';

void main() {
  group('Failures', () {
    test('AuthFailure creates with custom message', () {
      const failure = AuthFailure('Invalid credentials');
      expect(failure.message, equals('Invalid credentials'));
      expect(failure.props, equals(['Invalid credentials']));
    });

    test('NetworkFailure creates with default message', () {
      const failure = NetworkFailure();
      expect(failure.message, equals('Network connection failed'));
      expect(failure.props, equals(['Network connection failed']));
    });

    test('ServerFailure creates with custom message', () {
      const failure = ServerFailure('Internal server error');
      expect(failure.message, equals('Internal server error'));
      expect(failure.props, equals(['Internal server error']));
    });

    test('CacheFailure creates with default message', () {
      const failure = CacheFailure();
      expect(failure.message, equals('Cache error occurred'));
      expect(failure.props, equals(['Cache error occurred']));
    });

    test('ValidationFailure creates with custom message', () {
      const failure = ValidationFailure('Invalid input');
      expect(failure.message, equals('Invalid input'));
      expect(failure.props, equals(['Invalid input']));
    });

    test('PermissionFailure creates with custom message', () {
      const failure = PermissionFailure('Access denied');
      expect(failure.message, equals('Access denied'));
      expect(failure.props, equals(['Access denied']));
    });

    test('ImageUploadFailure creates with custom message', () {
      const failure = ImageUploadFailure('File too large');
      expect(failure.message, equals('File too large'));
      expect(failure.props, equals(['File too large']));
    });

    test('failures with same message are equal', () {
      const failure1 = AuthFailure('Test');
      const failure2 = AuthFailure('Test');
      expect(failure1, equals(failure2));
    });

    test('failures with different messages are not equal', () {
      const failure1 = AuthFailure('Test1');
      const failure2 = AuthFailure('Test2');
      expect(failure1, isNot(equals(failure2)));
    });

    test('different failure types are not equal', () {
      const authFailure = AuthFailure('Error');
      const serverFailure = ServerFailure('Error');
      expect(authFailure, isNot(equals(serverFailure)));
    });
  });
}
