import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppExceptions', () {
    test('should create exception with message and prefix', () {
      // arrange
      const message = 'Test message';
      const prefix = 'Test prefix: ';

      // act
      final exception = AppExceptions(message, prefix);

      // assert
      expect(exception.message, message);
      expect(exception.prefix, prefix);
      expect(exception.toString(), '$prefix$message');
    });

    test('should create exception with empty message and prefix', () {
      // act
      final exception = AppExceptions();

      // assert
      expect(exception.message, '');
      expect(exception.prefix, '');
      expect(exception.toString(), '');
    });
  });

  group('FetchDataException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Connection failed';

      // act
      final exception = FetchDataException(message);

      // assert
      expect(exception.message, message);
      expect(exception.toString(), 'Error During Communication: $message');
    });

    test('should create exception with default empty message', () {
      // act
      final exception = FetchDataException();

      // assert
      expect(exception.message, '');
      expect(exception.toString(), 'Error During Communication: ');
    });
  });

  group('BadRequestException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Invalid parameters';

      // act
      final exception = BadRequestException(message);

      // assert
      expect(exception.toString(), 'Invalid Request: $message');
    });
  });

  group('UnauthorisedException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Token expired';

      // act
      final exception = UnauthorisedException(message);

      // assert
      expect(exception.toString(), 'Unauthorised: $message');
    });
  });

  group('InvalidInputException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Invalid email format';

      // act
      final exception = InvalidInputException(message);

      // assert
      expect(exception.message, message);
      expect(exception.toString(), 'Invalid Input: $message');
    });

    test('should create exception with default empty message', () {
      // act
      final exception = InvalidInputException();

      // assert
      expect(exception.message, '');
      expect(exception.toString(), 'Invalid Input: ');
    });
  });

  group('NoInternetConnectionException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Please check your connection';

      // act
      final exception = NoInternetConnectionException(message);

      // assert
      expect(exception.toString(), 'No Internet Connection: $message');
    });
  });

  group('TimeoutException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Request took too long';

      // act
      final exception = TimeoutException(message);

      // assert
      expect(exception.toString(), 'Request Timeout: $message');
    });
  });

  group('ServerException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Internal server error';

      // act
      final exception = ServerException(message);

      // assert
      expect(exception.toString(), 'Server Error: $message');
    });
  });

  group('CacheException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Failed to read from cache';

      // act
      final exception = CacheException(message);

      // assert
      expect(exception.toString(), 'Cache Error: $message');
    });
  });

  group('AuthException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Invalid credentials';

      // act
      final exception = AuthException(message);

      // assert
      expect(exception.toString(), 'Authentication Error: $message');
    });
  });

  group('FirebaseException', () {
    test('should create exception with message', () {
      // arrange
      const message = 'Permission denied';

      // act
      final exception = FirebaseException(message);

      // assert
      expect(exception.toString(), 'Firebase Error: $message');
    });
  });

  group('Exception inheritance', () {
    test('all exceptions should extend AppExceptions', () {
      expect(FetchDataException(), isA<AppExceptions>());
      expect(BadRequestException(), isA<AppExceptions>());
      expect(UnauthorisedException(), isA<AppExceptions>());
      expect(InvalidInputException(), isA<AppExceptions>());
      expect(NoInternetConnectionException(), isA<AppExceptions>());
      expect(TimeoutException(), isA<AppExceptions>());
      expect(ServerException(), isA<AppExceptions>());
      expect(CacheException(), isA<AppExceptions>());
      expect(AuthException(), isA<AppExceptions>());
      expect(FirebaseException(), isA<AppExceptions>());
    });

    test('all exceptions should implement Exception', () {
      expect(AppExceptions(), isA<Exception>());
      expect(FetchDataException(), isA<Exception>());
      expect(BadRequestException(), isA<Exception>());
      expect(UnauthorisedException(), isA<Exception>());
      expect(InvalidInputException(), isA<Exception>());
      expect(NoInternetConnectionException(), isA<Exception>());
      expect(TimeoutException(), isA<Exception>());
      expect(ServerException(), isA<Exception>());
      expect(CacheException(), isA<Exception>());
      expect(AuthException(), isA<Exception>());
      expect(FirebaseException(), isA<Exception>());
    });
  });
}
