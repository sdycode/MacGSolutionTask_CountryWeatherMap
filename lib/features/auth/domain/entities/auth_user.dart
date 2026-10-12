import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    required this.isAnonymous,
    required this.emailVerified,
    this.createdAt,
  });

  final String uid;
  final String? email;
  final bool isAnonymous;
  final bool emailVerified;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    uid,
    email,
    isAnonymous,
    emailVerified,
    createdAt,
  ];
}
