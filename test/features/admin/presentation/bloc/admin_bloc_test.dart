import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/admin/domain/usecases/add_admin.dart';
import 'package:angry_raphi/features/admin/domain/usecases/check_admin_status.dart';
import 'package:angry_raphi/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'admin_bloc_test.mocks.dart';

@GenerateMocks([CheckAdminStatus, AddAdmin])
void main() {
  late MockCheckAdminStatus mockCheckAdminStatus;
  late MockAddAdmin mockAddAdmin;

  setUp(() {
    mockCheckAdminStatus = MockCheckAdminStatus();
    mockAddAdmin = MockAddAdmin();
  });

  const tEmail = 'test@example.com';
  const tUserId = 'user-123';
  const tDisplayName = 'Test User';

  group('AdminBloc', () {
    test('initial state is AdminInitial', () {
      // arrange & act
      final bloc = AdminBloc(mockCheckAdminStatus, mockAddAdmin);

      // assert
      expect(bloc.state, AdminInitial());

      // cleanup
      bloc.close();
    });

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminStatusChecked(true)] when user is admin',
      build: () {
        when(mockCheckAdminStatus(any))
            .thenAnswer((_) async => const Right(true));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent(tEmail)),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminStatusChecked(false)] when user is not admin',
      build: () {
        when(mockCheckAdminStatus(any))
            .thenAnswer((_) async => const Right(false));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent(tEmail)),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(false),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when check admin status fails',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Server error')));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(CheckAdminStatusEvent(tEmail)),
      expect: () => [
        AdminLoading(),
        AdminError('Server error'),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminStatusChecked(true)] when user is already admin',
      build: () {
        when(mockCheckAdminStatus(any))
            .thenAnswer((_) async => const Right(true));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      )),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
        verifyNever(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        ));
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminStatusChecked(true)] when user is made admin successfully',
      build: () {
        when(mockCheckAdminStatus(any))
            .thenAnswer((_) async => const Right(false));
        when(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async => const Right(null));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      )),
      expect: () => [
        AdminLoading(),
        AdminStatusChecked(true),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
        verify(mockAddAdmin(
          userId: tUserId,
          email: tEmail,
          displayName: tDisplayName,
        )).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when check fails in ensure admin',
      build: () {
        when(mockCheckAdminStatus(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Check failed')));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      )),
      expect: () => [
        AdminLoading(),
        AdminError('Check failed'),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
        verifyNever(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        ));
      },
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when adding admin fails',
      build: () {
        when(mockCheckAdminStatus(any))
            .thenAnswer((_) async => const Right(false));
        when(mockAddAdmin(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          displayName: anyNamed('displayName'),
        )).thenAnswer(
            (_) async => const Left(ServerFailure('Add failed')));
        return AdminBloc(mockCheckAdminStatus, mockAddAdmin);
      },
      act: (bloc) => bloc.add(EnsureCurrentUserIsAdminEvent(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      )),
      expect: () => [
        AdminLoading(),
        AdminError('Add failed'),
      ],
      verify: (_) {
        verify(mockCheckAdminStatus(tEmail)).called(1);
        verify(mockAddAdmin(
          userId: tUserId,
          email: tEmail,
          displayName: tDisplayName,
        )).called(1);
      },
    );
  });
}
