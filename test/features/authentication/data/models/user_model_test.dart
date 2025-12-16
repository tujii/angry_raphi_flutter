import 'package:angry_raphi/features/authentication/data/models/user_model.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_model_test.mocks.dart';

// Mock Firebase User
class MockFirebaseUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  MockFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

@GenerateMocks([Timestamp])
void main() {
  final tDateTime = DateTime(2024);
  final tUserModel = UserModel(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: 'https://example.com/photo.jpg',
    isAdmin: false,
    createdAt: tDateTime,
  );

  group('UserModel', () {
    test('should be a subclass of UserEntity', () {
      expect(tUserModel, isA<UserEntity>());
    });

    group('fromFirebaseUser', () {
      test('should create UserModel from Firebase user data', () {
        // arrange
        final firebaseUser = MockFirebaseUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
        );

        // act
        final result = UserModel.fromFirebaseUser(firebaseUser, false);

        // assert
        expect(result.id, firebaseUser.uid);
        expect(result.email, firebaseUser.email);
        expect(result.displayName, firebaseUser.displayName);
        expect(result.photoURL, firebaseUser.photoURL);
        expect(result.isAdmin, false);
      });

      test('should create admin UserModel when isAdmin is true', () {
        // arrange
        final firebaseUser = MockFirebaseUser(
          uid: 'admin-uid',
          email: 'admin@example.com',
          displayName: 'Admin User',
        );

        // act
        final result = UserModel.fromFirebaseUser(firebaseUser, true);

        // assert
        expect(result.isAdmin, true);
      });

      test('should handle null email with empty string', () {
        // arrange
        final firebaseUser = MockFirebaseUser(
          uid: 'test-uid',
          displayName: 'Test User',
        );

        // act
        final result = UserModel.fromFirebaseUser(firebaseUser, false);

        // assert
        expect(result.email, '');
      });

      test('should handle null displayName with empty string', () {
        // arrange
        final firebaseUser = MockFirebaseUser(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        // act
        final result = UserModel.fromFirebaseUser(firebaseUser, false);

        // assert
        expect(result.displayName, '');
      });

      test('should handle null photoURL', () {
        // arrange
        final firebaseUser = MockFirebaseUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // act
        final result = UserModel.fromFirebaseUser(firebaseUser, false);

        // assert
        expect(result.photoURL, null);
      });
    });

    group('fromMap', () {
      test('should create UserModel from valid map', () {
        // arrange
        final mockTimestamp = MockTimestamp();
        when(mockTimestamp.toDate()).thenReturn(tDateTime);

        final map = {
          'id': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
          'isAdmin': false,
          'createdAt': mockTimestamp,
        };

        // act
        final result = UserModel.fromMap(map);

        // assert
        expect(result.id, 'test-uid');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.photoURL, 'https://example.com/photo.jpg');
        expect(result.isAdmin, false);
        expect(result.createdAt, tDateTime);
      });

      test('should handle missing fields with default values', () {
        // arrange
        final map = <String, dynamic>{};

        // act
        final result = UserModel.fromMap(map);

        // assert
        expect(result.id, '');
        expect(result.email, '');
        expect(result.displayName, '');
        expect(result.photoURL, null);
        expect(result.isAdmin, false);
      });

      test('should handle null createdAt with DateTime.now()', () {
        // arrange
        final map = {
          'id': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
        };

        // act
        final result = UserModel.fromMap(map);

        // assert
        expect(result.createdAt, isNotNull);
      });
    });

    group('toMap', () {
      test('should convert UserModel to map', () {
        // arrange & act
        final result = tUserModel.toMap();

        // assert
        expect(result['id'], tUserModel.id);
        expect(result['email'], tUserModel.email);
        expect(result['displayName'], tUserModel.displayName);
        expect(result['photoURL'], tUserModel.photoURL);
        expect(result['isAdmin'], tUserModel.isAdmin);
        expect(result['createdAt'], isA<Timestamp>());
      });

      test('should handle null photoURL', () {
        // arrange
        final userWithoutPhoto = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: false,
          createdAt: tDateTime,
        );

        // act
        final result = userWithoutPhoto.toMap();

        // assert
        expect(result['photoURL'], null);
      });
    });

    group('copyWith', () {
      test('should return new instance with updated id', () {
        // act
        final result = tUserModel.copyWith(id: 'new-uid');

        // assert
        expect(result.id, 'new-uid');
        expect(result.email, tUserModel.email);
        expect(result.displayName, tUserModel.displayName);
      });

      test('should return new instance with updated email', () {
        // act
        final result = tUserModel.copyWith(email: 'new@example.com');

        // assert
        expect(result.id, tUserModel.id);
        expect(result.email, 'new@example.com');
      });

      test('should return new instance with updated displayName', () {
        // act
        final result = tUserModel.copyWith(displayName: 'New Name');

        // assert
        expect(result.displayName, 'New Name');
      });

      test('should return new instance with updated photoURL', () {
        // act
        final result = tUserModel.copyWith(photoURL: 'new-url');

        // assert
        expect(result.photoURL, 'new-url');
      });

      test('should return new instance with updated isAdmin', () {
        // act
        final result = tUserModel.copyWith(isAdmin: true);

        // assert
        expect(result.isAdmin, true);
      });

      test('should return new instance with updated createdAt', () {
        // arrange
        final newDateTime = DateTime(2024, 2);

        // act
        final result = tUserModel.copyWith(createdAt: newDateTime);

        // assert
        expect(result.createdAt, newDateTime);
      });

      test('should return same values when no parameters are provided', () {
        // act
        final result = tUserModel.copyWith();

        // assert
        expect(result.id, tUserModel.id);
        expect(result.email, tUserModel.email);
        expect(result.displayName, tUserModel.displayName);
        expect(result.photoURL, tUserModel.photoURL);
        expect(result.isAdmin, tUserModel.isAdmin);
        expect(result.createdAt, tUserModel.createdAt);
      });

      test('should update multiple fields at once', () {
        // act
        final result = tUserModel.copyWith(
          email: 'new@example.com',
          displayName: 'New Name',
          isAdmin: true,
        );

        // assert
        expect(result.email, 'new@example.com');
        expect(result.displayName, 'New Name');
        expect(result.isAdmin, true);
        expect(result.id, tUserModel.id);
      });
    });
  });
}
