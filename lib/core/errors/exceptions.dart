/// Custom exceptions for SisaSaku
class SisasakuException implements Exception {
  final String message;
  final String? code;

  SisasakuException({required this.message, this.code});

  @override
  String toString() => 'SisasakuException: $message';
}

class DatabaseException extends SisasakuException {
  DatabaseException({required super.message, super.code});
}

class CacheException extends SisasakuException {
  CacheException({required super.message, super.code});
}

class ServerException extends SisasakuException {
  ServerException({required super.message, super.code});
}

class NetworkException extends SisasakuException {
  NetworkException({required super.message, super.code});
}

class AuthException extends SisasakuException {
  AuthException({required super.message, super.code});
}
