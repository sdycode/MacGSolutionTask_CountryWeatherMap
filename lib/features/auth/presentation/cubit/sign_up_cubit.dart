import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_state.dart';

class SignUpCubit extends Cubit<AuthFormState> {
  SignUpCubit(this._auth) : super(const AuthFormState());

  final AuthRepository _auth;

  Future<void> signUp(String email, String password) async {
    emit(const AuthFormState(status: FormStatus.loading));
    final result = await _auth.signUp(email.trim(), password);
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
