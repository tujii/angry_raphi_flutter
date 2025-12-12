import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:angry_raphi/services/admin_service.dart';
import 'package:angry_raphi/features/admin/domain/repositories/admin_repository.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([AdminRepository, FirebaseAuth, User])
import 'admin_service_test.mocks.dart';

void main() {
  late AdminService adminService;
  late MockAdminRepository mockAdminRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    adminService = AdminService(
      adminRepository: mockAdminRepository,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  group('ensureAdminExists', () {
    const tEmail = 'admin@example.com';
    const tUserId = 'user123';
    const tDisplayName = 'Admin User';

    test('should do nothing when no current user', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verify(mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockAdminRepository);
    });

    test('should do nothing when current user email does not match', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('different@example.com');

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verifyNoMoreInteractions(mockAdminRepository);
    });

    test('should check admin status when current user email matches', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(true));

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verify(mockAdminRepository.checkAdminStatus(tUserId));
    });

    test('should add admin when user is not already admin', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(false));
      when(mockAdminRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verify(mockAdminRepository.addAdmin(tUserId, tEmail, tDisplayName));
    });

    test('should not add admin when user is already admin', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(true));

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verify(mockAdminRepository.checkAdminStatus(tUserId));
      verifyNever(mockAdminRepository.addAdmin(any, any, any));
    });

    test('should use email prefix as display name when displayName is null',
        () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(null);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(false));
      when(mockAdminRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      await adminService.ensureAdminExists(tEmail);

      // assert
      verify(mockAdminRepository.addAdmin(tUserId, tEmail, 'admin'));
    });

    test('should handle errors gracefully', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act & assert - should not throw
      await adminService.ensureAdminExists(tEmail);
    });
  });

  group('checkAndCreateCurrentUserAsAdmin', () {
    const tEmail = 'admin@example.com';
    const tUserId = 'user123';
    const tDisplayName = 'Admin User';

    test('should create admin when current user email matches', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(false));
      when(mockAdminRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      await adminService.checkAndCreateCurrentUserAsAdmin(tEmail);

      // assert
      verify(mockAdminRepository.checkAdminStatus(tUserId));
      verify(mockAdminRepository.addAdmin(tUserId, tEmail, tDisplayName));
    });

    test('should do nothing when current user email does not match', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('different@example.com');

      // act
      await adminService.checkAndCreateCurrentUserAsAdmin(tEmail);

      // assert
      verifyNoMoreInteractions(mockAdminRepository);
    });
  });

  group('checkAndUpdateAdminStatus', () {
    const tEmail = 'admin@example.com';
    const tUserId = 'user123';

    test('should return false when no current user', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // act
      final result = await adminService.checkAndUpdateAdminStatus();

      // assert
      expect(result, false);
    });

    test('should check admin status from repository', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await adminService.checkAndUpdateAdminStatus();

      // assert
      verify(mockAdminRepository.checkAdminStatus(tUserId));
    });

    test('should return true when user is admin', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await adminService.checkAndUpdateAdminStatus();

      // assert
      expect(result, true);
    });

    test('should return false when user is not admin', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await adminService.checkAndUpdateAdminStatus();

      // assert
      expect(result, false);
    });

    test('should return false when check admin status fails', () async {
      // arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.uid).thenReturn(tUserId);
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      // act
      final result = await adminService.checkAndUpdateAdminStatus();

      // assert
      expect(result, false);
    });
  });
}
