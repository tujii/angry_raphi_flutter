class AppExceptions implements Exception {
  final String message;
  final String prefix;

  AppExceptions([this.message = '', this.prefix = '']);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message])
      : super(message ?? '', 'Error During Communication: ');
}

class BadRequestException extends AppExceptions {
  BadRequestException([message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends AppExceptions {
  InvalidInputException([String? message])
      : super(message ?? '', 'Invalid Input: ');
}

class NoInternetConnectionException extends AppExceptions {
  NoInternetConnectionException([message])
      : super(message, 'No Internet Connection: ');
}

class TimeoutException extends AppExceptions {
  TimeoutException([message]) : super(message, 'Request Timeout: ');
}

class ServerException extends AppExceptions {
  ServerException([message]) : super(message, 'Server Error: ');
}

class CacheException extends AppExceptions {
  CacheException([message]) : super(message, 'Cache Error: ');
}

class AuthException extends AppExceptions {
  AuthException([message]) : super(message, 'Authentication Error: ');
}

class FirebaseException extends AppExceptions {
  FirebaseException([message]) : super(message, 'Firebase Error: ');
}
