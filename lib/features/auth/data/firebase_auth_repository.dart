import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/auth_user.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_error_mapper.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  AuthUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get userChanges => _auth.userChanges().map(_toUser);

  @override
  Future<Result<void>> signIn(String email, String password) {
    return _run(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  @override
  Future<Result<void>> signUp(String email, String password) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        await credential.user?.sendEmailVerification();
      } catch (_) {
        // can be resent from the verify screen
      }
    });
  }

  @override
  Future<Result<void>> signInAsGuest() => _run(_auth.signInAnonymously);

  @override
  Future<Result<void>> sendPasswordReset(String email) {
    return _run(() => _auth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<Result<void>> sendEmailVerification() {
    return _run(() async => _auth.currentUser?.sendEmailVerification());
  }

  @override
  Future<Result<void>> reloadUser() {
    return _run(() async => _auth.currentUser?.reload());
  }

  @override
  Future<Result<void>> signOut() {
    return _run(() async {
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        try {
          await user.delete();
        } catch (_) {
          // signing out below is enough
        }
      }
      await _auth.signOut();
    });
  }

  @override
  Future<Result<void>> deleteAccount({String? password}) {
    return _run(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      if (!user.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password ?? '',
        );
        await user.reauthenticateWithCredential(credential);
      }
      await user.delete();
    });
  }

  @override
  Future<Result<void>> discardUnverifiedAccount() {
    return _run(() async {
      try {
        await _auth.currentUser?.delete();
      } catch (_) {
        await _auth.signOut();
      }
    });
  }

  AuthUser? _toUser(User? user) {
    if (user == null) return null;

    return AuthUser(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
    );
  }

  Future<Result<void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } on FirebaseAuthException catch (error) {
      return Err(AuthFailure(authErrorMessage(error), code: error.code));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
