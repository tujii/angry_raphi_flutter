import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:angry_raphi/services/registered_users_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  User,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReferenceMap),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReferenceMap),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(as: #MockDocumentSnapshotMap),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshotMap),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
      as: #MockQueryDocumentSnapshotMap),
])
import 'registered_users_service_test.mocks.dart';

void main() {
  late RegisteredUsersService service;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReferenceMap mockCollectionReference;
  late MockDocumentReferenceMap mockDocumentReference;
  late MockDocumentSnapshotMap mockDocumentSnapshot;
  late MockUser mockUser;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReferenceMap();
    mockDocumentReference = MockDocumentReferenceMap();
    mockDocumentSnapshot = MockDocumentSnapshotMap();
    mockUser = MockUser();

    service = RegisteredUsersService(mockFirestore);

    when(mockFirestore.collection('registeredUsers'))
        .thenReturn(mockCollectionReference);
  });

  group('saveRegisteredUser', () {
    const tUid = 'user123';
    const tEmail = 'test@example.com';
    const tDisplayName = 'Test User';

    setUp(() {
      when(mockUser.uid).thenReturn(tUid);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockUser.photoURL).thenReturn(null);
    });

    test('should create new user document when user does not exist', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // act
      await service.saveRegisteredUser(mockUser);

      // assert
      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should update existing user document when user exists', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      // act
      await service.saveRegisteredUser(mockUser);

      // assert
      verify(mockDocumentReference.update(any)).called(1);
      verifyNever(mockDocumentReference.set(any));
    });

    test('should use email prefix as display name when displayName is null',
        () async {
      // arrange
      when(mockUser.displayName).thenReturn(null);
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // act
      await service.saveRegisteredUser(mockUser);

      // assert
      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should not throw when save fails', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenThrow(Exception('Firestore error'));

      // act & assert - should not throw
      await service.saveRegisteredUser(mockUser);
    });
  });

  group('isUserRegistered', () {
    const tUid = 'user123';

    test('should return true when user exists', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);

      // act
      final result = await service.isUserRegistered(tUid);

      // assert
      expect(result, true);
    });

    test('should return false when user does not exist', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // act
      final result = await service.isUserRegistered(tUid);

      // assert
      expect(result, false);
    });

    test('should return false when error occurs', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenThrow(Exception('Firestore error'));

      // act
      final result = await service.isUserRegistered(tUid);

      // assert
      expect(result, false);
    });
  });

  group('getRegisteredUser', () {
    const tUid = 'user123';
    final tUserData = {
      'uid': tUid,
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': null,
    };

    test('should return user data when user exists', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(tUserData);
      when(mockDocumentSnapshot.id).thenReturn(tUid);

      // act
      final result = await service.getRegisteredUser(tUid);

      // assert
      expect(result, isNotNull);
      expect(result!['uid'], tUid);
      expect(result['email'], 'test@example.com');
    });

    test('should return null when user does not exist', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // act
      final result = await service.getRegisteredUser(tUid);

      // assert
      expect(result, isNull);
    });

    test('should return null when error occurs', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenThrow(Exception('Firestore error'));

      // act
      final result = await service.getRegisteredUser(tUid);

      // assert
      expect(result, isNull);
    });
  });

  group('deleteRegisteredUser', () {
    const tUid = 'user123';

    test('should delete user document', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.delete()).thenAnswer((_) async => {});

      // act
      await service.deleteRegisteredUser(tUid);

      // assert
      verify(mockDocumentReference.delete()).called(1);
    });

    test('should throw exception when delete fails', () async {
      // arrange
      when(mockCollectionReference.doc(tUid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.delete()).thenThrow(Exception('Delete failed'));

      // act & assert
      expect(
        () => service.deleteRegisteredUser(tUid),
        throwsException,
      );
    });
  });
}
