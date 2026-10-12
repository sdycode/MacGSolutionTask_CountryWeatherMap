import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('No internet connection. Please check your network.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timed out. Please try again.');
}

class ServerFailure extends Failure {
  const ServerFailure(int statusCode)
    : super('Server error ($statusCode). Please try again.');
}

class InvalidResponseFailure extends Failure {
  const InvalidResponseFailure()
    : super('Received an invalid response from the server.');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.code});

  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Something went wrong. Please try again.');
}
