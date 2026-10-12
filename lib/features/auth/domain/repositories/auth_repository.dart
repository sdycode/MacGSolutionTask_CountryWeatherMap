import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get userChanges;

  Future<Result<void>> signIn(String email, String password);

  Future<Result<void>> signUp(String email, String password);

  Future<Result<void>> signInAsGuest();

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> sendEmailVerification();

  Future<Result<void>> reloadUser();

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount({String? password});

  Future<Result<void>> discardUnverifiedAccount();
}
