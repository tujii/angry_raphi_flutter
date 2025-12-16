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
  BadRequestException([String? message])
      : super(message ?? '', 'Invalid Request: ');
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException([String? message])
      : super(message ?? '', 'Unauthorised: ');
}

class InvalidInputException extends AppExceptions {
  InvalidInputException([String? message])
      : super(message ?? '', 'Invalid Input: ');
}

class NoInternetConnectionException extends AppExceptions {
  NoInternetConnectionException([String? message])
      : super(message ?? '', 'No Internet Connection: ');
}

class TimeoutException extends AppExceptions {
  TimeoutException([String? message])
      : super(message ?? '', 'Request Timeout: ');
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message ?? '', 'Server Error: ');
}

class CacheException extends AppExceptions {
  CacheException([String? message]) : super(message ?? '', 'Cache Error: ');
}

class AuthException extends AppExceptions {
  AuthException([String? message])
      : super(message ?? '', 'Authentication Error: ');
}

class FirebaseException extends AppExceptions {
  FirebaseException([String? message])
      : super(message ?? '', 'Firebase Error: ');
}
