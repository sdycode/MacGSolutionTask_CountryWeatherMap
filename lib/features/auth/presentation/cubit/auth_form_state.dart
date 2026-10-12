import 'package:equatable/equatable.dart';

enum FormStatus { idle, loading, success, failure }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.status = FormStatus.idle,
    this.message,
    this.isGuest = false,
  });

  final FormStatus status;
  final String? message;
  final bool isGuest;

  bool get isLoading => status == FormStatus.loading;

  @override
  List<Object?> get props => [status, message, isGuest];
}
