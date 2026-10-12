import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_state.dart';

class ForgotPasswordCubit extends Cubit<AuthFormState> {
  ForgotPasswordCubit(this._auth) : super(const AuthFormState());

  final AuthRepository _auth;

  Future<void> sendResetLink(String email) async {
    emit(const AuthFormState(status: FormStatus.loading));
    final result = await _auth.sendPasswordReset(email.trim());
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

  void reset() => emit(const AuthFormState());
}
