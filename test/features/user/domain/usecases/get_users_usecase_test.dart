import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:angry_raphi/features/user/domain/repositories/user_repository.dart';
import 'package:angry_raphi/features/user/domain/usecases/user_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_users_usecase_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
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

  group('GetUsersUseCase', () {
    test('should get users from repository', () async {
      // arrange
      when(mockRepository.getUsers()).thenAnswer((_) async => tUserList);
      final useCase = GetUsersUseCase(mockRepository);

      // act
      final result = await useCase.execute();

      // assert
      expect(result, tUserList);
      verify(mockRepository.getUsers());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no users exist', () async {
      // arrange
      when(mockRepository.getUsers()).thenAnswer((_) async => []);
      final useCase = GetUsersUseCase(mockRepository);

      // act
      final result = await useCase.execute();

      // assert
      expect(result, []);
      verify(mockRepository.getUsers());
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetUsersStreamUseCase', () {
    test('should get users stream from repository', () {
      // arrange
      when(mockRepository.getUsersStream())
          .thenAnswer((_) => Stream.value(tUserList));
      final useCase = GetUsersStreamUseCase(mockRepository);

      // act
      final result = useCase.execute();

      // assert
      expect(result, emits(tUserList));
      verify(mockRepository.getUsersStream());
    });
  });

  group('AddUserUseCase', () {
    final tUser = User(
      id: 'new-id',
      initials: 'T.U.',
      totalRaphcons: 0,
      lastUpdated: DateTime.now(),
    );

    test('should add user when validation passes', () async {
      // arrange
      when(mockRepository.addUser(any)).thenAnswer((_) async => true);
      final useCase = AddUserUseCase(mockRepository);

      // act
      final result = await useCase.execute(tUser);

      // assert
      expect(result, true);
      verify(mockRepository.addUser(tUser));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ArgumentError when initials are empty', () async {
      // arrange
      final invalidUser = User(
        id: 'new-id',
        initials: '',
        totalRaphcons: 0,
        lastUpdated: DateTime.now(),
      );
      final useCase = AddUserUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute(invalidUser),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.addUser(any));
    });

    test('should throw ArgumentError when initials format is invalid',
        () async {
      // arrange
      final invalidUser = User(
        id: 'new-id',
        initials: 'ABC',
        totalRaphcons: 0,
        lastUpdated: DateTime.now(),
      );
      final useCase = AddUserUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute(invalidUser),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.addUser(any));
    });

    test('should throw ArgumentError when initials are lowercase', () async {
      // arrange
      final invalidUser = User(
        id: 'new-id',
        initials: 'a.b.',
        totalRaphcons: 0,
        lastUpdated: DateTime.now(),
      );
      final useCase = AddUserUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute(invalidUser),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.addUser(any));
    });
  });

  group('UpdateUserRaphconsUseCase', () {
    test('should update user raphcons when count is valid', () async {
      // arrange
      when(mockRepository.updateUserRaphcons(any, any))
          .thenAnswer((_) async => true);
      final useCase = UpdateUserRaphconsUseCase(mockRepository);

      // act
      final result = await useCase.execute('user-123', 15);

      // assert
      expect(result, true);
      verify(mockRepository.updateUserRaphcons('user-123', 15));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ArgumentError when count is negative', () async {
      // arrange
      final useCase = UpdateUserRaphconsUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute('user-123', -1),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.updateUserRaphcons(any, any));
    });

    test('should accept zero as valid count', () async {
      // arrange
      when(mockRepository.updateUserRaphcons(any, any))
          .thenAnswer((_) async => true);
      final useCase = UpdateUserRaphconsUseCase(mockRepository);

      // act
      final result = await useCase.execute('user-123', 0);

      // assert
      expect(result, true);
      verify(mockRepository.updateUserRaphcons('user-123', 0));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteUserUseCase', () {
    test('should delete user when userId is valid', () async {
      // arrange
      when(mockRepository.deleteUser(any)).thenAnswer((_) async => true);
      final useCase = DeleteUserUseCase(mockRepository);

      // act
      final result = await useCase.execute('user-123');

      // assert
      expect(result, true);
      verify(mockRepository.deleteUser('user-123'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ArgumentError when userId is empty', () async {
      // arrange
      final useCase = DeleteUserUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute(''),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.deleteUser(any));
    });

    test('should throw ArgumentError when userId is only whitespace',
        () async {
      // arrange
      final useCase = DeleteUserUseCase(mockRepository);

      // act & assert
      expect(
        () => useCase.execute('   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.deleteUser(any));
    });
  });
}
