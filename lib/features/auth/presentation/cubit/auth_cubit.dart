import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(AuthRepository repository) : super(const AuthUnknown()) {
    _subscription = repository.userChanges.listen((user) {
      emit(user == null ? const Unauthenticated() : Authenticated(user));
    });
  }

  StreamSubscription<AuthUser?>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
