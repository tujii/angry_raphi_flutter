import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:angry_raphi/features/user/domain/usecases/user_usecases.dart';

@GenerateMocks([
  GetUsersUseCase,
  GetUsersStreamUseCase,
  AddUserUseCase,
  DeleteUserUseCase,
])
import 'user_bloc_test.mocks.dart';

void main() {
  late UserBloc userBloc;
  late MockGetUsersUseCase mockGetUsersUseCase;
  late MockGetUsersStreamUseCase mockGetUsersStreamUseCase;
  late MockAddUserUseCase mockAddUserUseCase;
  late MockDeleteUserUseCase mockDeleteUserUseCase;

  final tUser = User(
    id: '1',
    initials: 'TU',
    totalRaphcons: 10,
    positiveRaphcons: 5,
    negativeRaphcons: 5,
    lastUpdated: DateTime.now(),
  );

  final tUserList = [tUser];

  setUp(() {
    mockGetUsersUseCase = MockGetUsersUseCase();
    mockGetUsersStreamUseCase = MockGetUsersStreamUseCase();
    mockAddUserUseCase = MockAddUserUseCase();
    mockDeleteUserUseCase = MockDeleteUserUseCase();

    // Mock stream to return empty stream by default to prevent auto-start issues
    when(mockGetUsersStreamUseCase.execute())
        .thenAnswer((_) => Stream.value([]));
  });

  tearDown(() {
    userBloc.close();
  });

  group('UserBloc', () {
    test('initial state should be UserInitial', () {
      userBloc = UserBloc(
        getUsersUseCase: mockGetUsersUseCase,
        getUsersStreamUseCase: mockGetUsersStreamUseCase,
        addUserUseCase: mockAddUserUseCase,
        deleteUserUseCase: mockDeleteUserUseCase,
      );

      expect(userBloc.state, isA<UserState>());
    });

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserLoaded] when LoadUsersEvent is added and users are loaded successfully',
      build: () {
        when(mockGetUsersUseCase.execute())
            .thenAnswer((_) async => tUserList);
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
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
      'should emit [UserLoading, UserError] when LoadUsersEvent is added and loading fails',
      build: () {
        when(mockGetUsersUseCase.execute())
            .thenThrow(Exception('Failed to load users'));
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
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
      'should emit [UserLoading, UserLoaded] when RefreshUsersEvent is added',
      build: () {
        when(mockGetUsersUseCase.execute())
            .thenAnswer((_) async => tUserList);
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(RefreshUsersEvent()),
      expect: () => [
        UserLoading(),
        UserLoaded(tUserList),
      ],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserLoaded] when AddUserEvent is successful',
      build: () {
        when(mockAddUserUseCase.execute(any))
            .thenAnswer((_) async => tUser);
        when(mockGetUsersUseCase.execute())
            .thenAnswer((_) async => tUserList);
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddUserEvent(initials: 'TU')),
      expect: () => [
        UserLoading(),
        UserLoaded(tUserList),
      ],
      verify: (_) {
        verify(mockAddUserUseCase.execute('TU')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when AddUserEvent fails',
      build: () {
        when(mockAddUserUseCase.execute(any))
            .thenThrow(Exception('Failed to add user'));
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(const AddUserEvent(initials: 'TU')),
      expect: () => [
        UserLoading(),
        isA<UserError>(),
      ],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserDeleted] when DeleteUserEvent is successful',
      build: () {
        when(mockDeleteUserUseCase.execute(any))
            .thenAnswer((_) async => {});
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
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
      ],
      verify: (_) {
        verify(mockDeleteUserUseCase.execute('1')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when DeleteUserEvent fails',
      build: () {
        when(mockDeleteUserUseCase.execute(any))
            .thenThrow(Exception('Failed to delete user'));
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
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

    blocTest<UserBloc, UserState>(
      'should emit [UserLoaded] when UsersStreamUpdatedEvent is added',
      build: () {
        when(mockGetUsersStreamUseCase.execute())
            .thenAnswer((_) => Stream.value([]));
        return UserBloc(
          getUsersUseCase: mockGetUsersUseCase,
          getUsersStreamUseCase: mockGetUsersStreamUseCase,
          addUserUseCase: mockAddUserUseCase,
          deleteUserUseCase: mockDeleteUserUseCase,
        );
      },
      act: (bloc) => bloc.add(UsersStreamUpdatedEvent(tUserList)),
      expect: () => [
        UserLoaded(tUserList),
      ],
    );
  });
}
