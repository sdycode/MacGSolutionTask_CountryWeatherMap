import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_state.dart';

class LoginCubit extends Cubit<AuthFormState> {
  LoginCubit(this._auth) : super(const AuthFormState());

  final AuthRepository _auth;

  Future<void> signIn(String email, String password) async {
    emit(const AuthFormState(status: FormStatus.loading));
    _emitResult(await _auth.signIn(email.trim(), password));
  }

  Future<void> continueAsGuest() async {
    emit(const AuthFormState(status: FormStatus.loading, isGuest: true));
    _emitResult(await _auth.signInAsGuest());
  }

  void _emitResult(Result<void> result) {
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(const AuthFormState(status: FormStatus.success));
      case Err(:final failure):
        emit(
          AuthFormState(status: FormStatus.failure, message: failure.message),
        );
    }
  }
}
