import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:angry_raphi/features/admin/domain/usecases/check_admin_status.dart';
import 'package:angry_raphi/features/admin/domain/usecases/add_admin.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([CheckAdminStatus, AddAdmin])
import 'admin_bloc_test.mocks.dart';

void main() {
  late AdminBloc adminBloc;
  late MockCheckAdminStatus mockCheckAdminStatus;
  late MockAddAdmin mockAddAdmin;

  setUp(() {
    mockCheckAdminStatus = MockCheckAdminStatus();
    mockAddAdmin = MockAddAdmin();
  });

  tearDown(() {
    adminBloc.close();
  });

  group('AdminBloc', () {
    test('initial state should be AdminInitial', () {
      adminBloc = AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      expect(adminBloc.state, equals(AdminInitial()));
    });

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminStatusChecked(true)] when CheckAdminStatusEvent is added and user is admin',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer((_) async => const Right(true));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent('user123')),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus('user123')).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminStatusChecked(false)] when CheckAdminStatusEvent is added and user is not admin',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer((_) async => const Right(false));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent('user123')),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(false),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminError] when CheckAdminStatusEvent fails',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to check admin status')),
        );
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent('user123')),
      expect: () => [
        AdminLoading(),
        AdminError('Failed to check admin status'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminStatusChecked(true)] when EnsureCurrentUserIsAdminEvent is added and user is already admin',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer((_) async => const Right(true));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: 'user123',
        email: 'admin@example.com',
        displayName: 'Admin User',
      )),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus('user123')).called(1);
        verifyNever(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        ));
      },
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminStatusChecked(true)] when EnsureCurrentUserIsAdminEvent is added and user is added as admin',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer((_) async => const Right(false));
        when(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => const Right(null));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: 'user123',
        email: 'admin@example.com',
        displayName: 'Admin User',
      )),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus('user123')).called(1);
        verify(mockAddAdmin(
          userId: 'user123',
          email: 'admin@example.com',
          displayName: 'Admin User',
        )).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminError] when EnsureCurrentUserIsAdminEvent check status fails',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to check status')),
        );
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: 'user123',
        email: 'admin@example.com',
        displayName: 'Admin User',
      )),
      expect: () => [
        AdminLoading(),
        AdminError('Failed to check status'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'should emit [AdminLoading, AdminError] when EnsureCurrentUserIsAdminEvent adding admin fails',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer((_) async => const Right(false));
        when(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => const Left(ServerFailure('Failed to add admin')));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: 'user123',
        email: 'admin@example.com',
        displayName: 'Admin User',
      )),
      expect: () => [
        AdminLoading(),
        AdminError('Failed to add admin'),
      ],
    );
  });
}
