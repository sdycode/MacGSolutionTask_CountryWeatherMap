import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';

class VerifyEmailState extends Equatable {
  const VerifyEmailState({
    this.isChecking = false,
    this.isLeaving = false,
    this.resendCooldown = 0,
    this.message,
  });

  final bool isChecking;
  final bool isLeaving;
  final int resendCooldown;
  final String? message;

  VerifyEmailState copyWith({
    bool? isChecking,
    bool? isLeaving,
    int? resendCooldown,
    String? message,
  }) {
    return VerifyEmailState(
      isChecking: isChecking ?? this.isChecking,
      isLeaving: isLeaving ?? this.isLeaving,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      message: message,
    );
  }

  @override
  List<Object?> get props => [isChecking, isLeaving, resendCooldown, message];
}

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(this._auth) : super(const VerifyEmailState()) {
    _checkTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _auth.reloadUser(),
    );
    _startCooldown();
  }

  final AuthRepository _auth;
  Timer? _checkTimer;
  Timer? _cooldownTimer;

  Future<void> checkNow() async {
    emit(state.copyWith(isChecking: true));
    final result = await _auth.reloadUser();
    if (isClosed) return;

    final user = _auth.currentUser;
    String? message;
    if (result is Err<void>) {
      message = result.failure.message;
    } else if (user != null && !user.emailVerified) {
      message = 'Your email is not verified yet. Open the link we sent you.';
    }
    emit(state.copyWith(isChecking: false, message: message));
  }

  Future<void> resend() async {
    final result = await _auth.sendEmailVerification();
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            message: 'Verification email sent. Check your inbox and spam.',
          ),
        );
        _startCooldown();
      case Err(:final failure):
        emit(state.copyWith(message: failure.message));
        if (failure is AuthFailure && failure.code == 'too-many-requests') {
          _startCooldown();
        }
    }
  }

  Future<void> startOver() async {
    emit(state.copyWith(isLeaving: true));
    await _auth.discardUnverifiedAccount();
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLeaving: true));
    await _auth.signOut();
  }

  void _startCooldown() {
    emit(state.copyWith(resendCooldown: 60));
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown <= 1) timer.cancel();
      emit(state.copyWith(resendCooldown: state.resendCooldown - 1));
    });
  }

  @override
  Future<void> close() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    return super.close();
  }
}
