/// Failures for SisaSaku (used with Either pattern)
sealed class Failure {
  final String message;
  final String? code;

  Failure({required this.message, this.code});
}

class DatabaseFailure extends Failure {
  DatabaseFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  CacheFailure({required super.message, super.code});
}

class ServerFailure extends Failure {
  ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  NetworkFailure({required super.message, super.code});
}

class AuthFailure extends Failure {
  AuthFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  ValidationFailure({required super.message, super.code});
}
