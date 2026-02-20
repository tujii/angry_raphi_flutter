import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:angry_raphi/features/user/domain/usecases/user_usecases.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_bloc_test.mocks.dart';

@GenerateMocks([
  GetUsersUseCase,
  GetUsersStreamUseCase,
  AddUserUseCase,
  DeleteUserUseCase,
])
void main() {
  late MockGetUsersUseCase mockGetUsersUseCase;
  late MockGetUsersStreamUseCase mockGetUsersStreamUseCase;
  late MockAddUserUseCase mockAddUserUseCase;
  late MockDeleteUserUseCase mockDeleteUserUseCase;

  setUp(() {
    mockGetUsersUseCase = MockGetUsersUseCase();
    mockGetUsersStreamUseCase = MockGetUsersStreamUseCase();
    mockAddUserUseCase = MockAddUserUseCase();
    mockDeleteUserUseCase = MockDeleteUserUseCase();

    // Default stub for stream - return empty stream
    when(mockGetUsersStreamUseCase.execute())
        .thenAnswer((_) => const Stream.empty());
  });

  final tUser1 = User(
    id: '1',
    initials: 'J.D.',
    totalRaphcons: 10,
    lastUpdated: DateTime(2024, 1, 1),
  );

  final tUser2 = User(
    id: '2',
    initials: 'A.B.',
    totalRaphcons: 5,
    lastUpdated: DateTime(2024, 1, 2),
  );

  final tUserList = [tUser1, tUser2];

  group('UserBloc', () {
    test('initial state is UserInitial', () {
      // arrange
      final bloc = UserBloc(
        getUsersUseCase: mockGetUsersUseCase,
        getUsersStreamUseCase: mockGetUsersStreamUseCase,
        addUserUseCase: mockAddUserUseCase,
        deleteUserUseCase: mockDeleteUserUseCase,
      );

      // assert
      expect(bloc.state, UserInitial());

      // cleanup
      bloc.close();
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when LoadUsersEvent is successful',
      build: () {
        when(mockGetUsersUseCase.execute()).thenAnswer((_) async => tUserList);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(LoadUsersEvent()),
      expect: () => [
        UserLoading(),
        UserLoaded(tUserList),
      ],
      verify: (_) {
        verify(mockGetUsersUseCase.execute()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] with empty list when no users exist',
      build: () {
        when(mockGetUsersUseCase.execute()).thenAnswer((_) async => []);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(LoadUsersEvent()),
      expect: () => [
        UserLoading(),
        const UserLoaded([]),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when LoadUsersEvent fails',
      build: () {
        when(mockGetUsersUseCase.execute()).thenThrow(Exception('Test error'));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(LoadUsersEvent()),
      expect: () => [
        UserLoading(),
        isA<UserError>(),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when stream emits data',
      build: () {
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value(tUserList));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        UserLoading(),
        UserLoaded(tUserList),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading] when AddUserEvent is added and succeeds',
      build: () {
        when(mockAddUserUseCase.execute(any)).thenAnswer((_) async => true);
        when(mockGetUsersUseCase.execute()).thenAnswer((_) async => tUserList);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddUserEvent(initials: 'T.U.')),
      expect: () => [
        UserLoading(),
        UserLoading(), // From LoadUsersEvent triggered after add
        UserLoaded(tUserList),
      ],
      verify: (_) {
        verify(mockAddUserUseCase.execute(any)).called(1);
        verify(mockGetUsersUseCase.execute()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when AddUserEvent fails',
      build: () {
        when(mockAddUserUseCase.execute(any)).thenAnswer((_) async => false);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddUserEvent(initials: 'T.U.')),
      expect: () => [
        UserLoading(),
        const UserError('failedToAddUser'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when AddUserEvent throws exception',
      build: () {
        when(mockAddUserUseCase.execute(any))
            .thenThrow(ArgumentError('Invalid initials'));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddUserEvent(initials: 'invalid')),
      expect: () => [
        UserLoading(),
        isA<UserError>(),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserDeleted, UserLoading, UserLoaded] when DeleteUserEvent succeeds',
      build: () {
        when(mockDeleteUserUseCase.execute(any)).thenAnswer((_) async => true);
        when(mockGetUsersUseCase.execute()).thenAnswer((_) async => [tUser2]);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const DeleteUserEvent('1')),
      expect: () => [
        UserLoading(),
        const UserDeleted('1'),
        UserLoading(),
        UserLoaded([tUser2]),
      ],
      verify: (_) {
        verify(mockDeleteUserUseCase.execute('1')).called(1);
        verify(mockGetUsersUseCase.execute()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when DeleteUserEvent fails',
      build: () {
        when(mockDeleteUserUseCase.execute(any)).thenAnswer((_) async => false);
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const DeleteUserEvent('1')),
      expect: () => [
        UserLoading(),
        const UserError('failedToDeleteUser'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when DeleteUserEvent throws exception',
      build: () {
        when(mockDeleteUserUseCase.execute(any))
            .thenThrow(Exception('Delete failed'));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const DeleteUserEvent('1')),
      expect: () => [
        UserLoading(),
        isA<UserError>(),
      ],
    );

    test('closes stream subscription on close', () async {
      // arrange
      final bloc = UserBloc(
        getUsersUseCase: mockGetUsersUseCase,
        getUsersStreamUseCase: mockGetUsersStreamUseCase,
        addUserUseCase: mockAddUserUseCase,
        deleteUserUseCase: mockDeleteUserUseCase,
      );

      // act
      await bloc.close();

      // assert - no exception should be thrown
      expect(bloc.isClosed, true);
    });
  });
}
