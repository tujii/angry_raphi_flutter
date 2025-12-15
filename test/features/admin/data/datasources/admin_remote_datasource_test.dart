import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:angry_raphi/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:angry_raphi/features/admin/data/models/admin_model.dart';
import 'package:angry_raphi/core/errors/exceptions.dart';

import 'admin_remote_datasource_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  WriteBatch,
  Query,
])
void main() {
  group('AdminRemoteDataSourceImpl', () {
    late AdminRemoteDataSourceImpl dataSource;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockAdminsCollection;
    late MockCollectionReference<Map<String, dynamic>> mockAdminEmailsCollection;
    late MockDocumentReference<Map<String, dynamic>> mockAdminDoc;
    late MockDocumentReference<Map<String, dynamic>> mockAdminEmailDoc;
    late MockWriteBatch mockBatch;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocSnapshot;
    late MockQuery<Map<String, dynamic>> mockQuery;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAdminsCollection = MockCollectionReference<Map<String, dynamic>>();
      mockAdminEmailsCollection = MockCollectionReference<Map<String, dynamic>>();
      mockAdminDoc = MockDocumentReference<Map<String, dynamic>>();
      mockAdminEmailDoc = MockDocumentReference<Map<String, dynamic>>();
      mockBatch = MockWriteBatch();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockQueryDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      mockQuery = MockQuery<Map<String, dynamic>>();

      dataSource = AdminRemoteDataSourceImpl(mockFirestore);

      // Setup default firestore behavior
      when(mockFirestore.collection('admins')).thenReturn(mockAdminsCollection);
      when(mockFirestore.collection('adminEmails')).thenReturn(mockAdminEmailsCollection);
      when(mockFirestore.batch()).thenReturn(mockBatch);
    });

    group('addAdmin', () {
      const String testUserId = 'test_user_id';
      const String testEmail = 'test@example.com';
      const String testDisplayName = 'Test Admin';

      test('should successfully add admin to both admins and adminEmails collections', () async {
        // Arrange
        when(mockAdminsCollection.doc(testUserId)).thenReturn(mockAdminDoc);
        when(mockAdminEmailsCollection.doc(testEmail)).thenReturn(mockAdminEmailDoc);
        when(mockBatch.set(any, any)).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => []);

        // Act
        await dataSource.addAdmin(testUserId, testEmail, testDisplayName);

        // Assert
        verify(mockFirestore.batch()).called(1);
        verify(mockAdminsCollection.doc(testUserId)).called(1);
        verify(mockAdminEmailsCollection.doc(testEmail)).called(1);
        verify(mockBatch.set(mockAdminDoc, any)).called(1);
        verify(mockBatch.set(mockAdminEmailDoc, {'exists': true, 'createdAt': FieldValue.serverTimestamp()})).called(1);
        verify(mockBatch.commit()).called(1);
      });

      test('should throw ServerException when batch commit fails', () async {
        // Arrange
        when(mockAdminsCollection.doc(testUserId)).thenReturn(mockAdminDoc);
        when(mockAdminEmailsCollection.doc(testEmail)).thenReturn(mockAdminEmailDoc);
        when(mockBatch.set(any, any)).thenReturn(mockBatch);
        when(mockBatch.commit()).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () async => await dataSource.addAdmin(testUserId, testEmail, testDisplayName),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('removeAdmin', () {
      const String testEmail = 'test@example.com';
      const String testUserId = 'test_user_id';

      test('should successfully remove admin from both collections when admin exists', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(mockQueryDocSnapshot.id).thenReturn(testUserId);
        when(mockAdminsCollection.doc(testUserId)).thenReturn(mockAdminDoc);
        when(mockAdminEmailsCollection.doc(testEmail)).thenReturn(mockAdminEmailDoc);
        when(mockBatch.update(any, any)).thenReturn(mockBatch);
        when(mockBatch.delete(any)).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => []);

        // Act
        await dataSource.removeAdmin(testEmail);

        // Assert
        verify(mockFirestore.batch()).called(1);
        verify(mockAdminsCollection.where('email', isEqualTo: testEmail)).called(1);
        verify(mockQuery.limit(1)).called(1);
        verify(mockQuery.get()).called(1);
        verify(mockBatch.update(mockAdminDoc, {'isActive': false})).called(1);
        verify(mockBatch.delete(mockAdminEmailDoc)).called(1);
        verify(mockBatch.commit()).called(1);
      });

      test('should throw ServerException when admin not found', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Act & Assert
        expect(
          () async => await dataSource.removeAdmin(testEmail),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException when batch commit fails', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(mockQueryDocSnapshot.id).thenReturn(testUserId);
        when(mockAdminsCollection.doc(testUserId)).thenReturn(mockAdminDoc);
        when(mockAdminEmailsCollection.doc(testEmail)).thenReturn(mockAdminEmailDoc);
        when(mockBatch.update(any, any)).thenReturn(mockBatch);
        when(mockBatch.delete(any)).thenReturn(mockBatch);
        when(mockBatch.commit()).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () async => await dataSource.removeAdmin(testEmail),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('checkAdminStatus', () {
      const String testEmail = 'test@example.com';

      test('should return true when admin exists and is active', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

        // Act
        final result = await dataSource.checkAdminStatus(testEmail);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when admin does not exist', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await dataSource.checkAdminStatus(testEmail);

        // Assert
        expect(result, isFalse);
      });

      test('should throw ServerException when query fails', () async {
        // Arrange
        when(mockAdminsCollection.where('email', isEqualTo: testEmail)).thenReturn(mockQuery);
        when(mockQuery.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () async => await dataSource.checkAdminStatus(testEmail),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getAllAdmins', () {
      test('should return list of admin models when admins exist', () async {
        // Arrange
        final mockData = {
          'email': 'admin@example.com',
          'displayName': 'Admin User',
          'createdAt': Timestamp.now(),
          'isActive': true,
        };
        
        when(mockAdminsCollection.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
        when(mockQueryDocSnapshot.data()).thenReturn(mockData);
        when(mockQueryDocSnapshot.id).thenReturn('admin_id');

        // Act
        final result = await dataSource.getAllAdmins();

        // Assert
        expect(result, isA<List<AdminModel>>());
        expect(result.length, equals(1));
        expect(result[0].email, equals('admin@example.com'));
        expect(result[0].displayName, equals('Admin User'));
        expect(result[0].id, equals('admin_id'));
      });

      test('should return empty list when no active admins exist', () async {
        // Arrange
        when(mockAdminsCollection.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await dataSource.getAllAdmins();

        // Assert
        expect(result, isA<List<AdminModel>>());
        expect(result.length, equals(0));
      });

      test('should throw ServerException when query fails', () async {
        // Arrange
        when(mockAdminsCollection.where('isActive', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () async => await dataSource.getAllAdmins(),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}