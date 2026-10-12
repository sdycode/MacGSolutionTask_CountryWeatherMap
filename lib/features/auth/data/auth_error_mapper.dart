import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Something went wrong. Please try again.';
  }

  return switch (error.code) {
    'invalid-email' => 'Please enter a valid email address.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Incorrect email or password.',
    'user-disabled' => 'This account has been disabled.',
    'email-already-in-use' =>
      'An account already exists for this email. Try signing in instead.',
    'weak-password' => 'Password is too weak. Try a stronger one.',
    'too-many-requests' =>
      'Too many attempts. Please wait a few minutes and try again.',
    'network-request-failed' =>
      'No internet connection. Please check your network.',
    'operation-not-allowed' => 'This sign-in method is not enabled.',
    'requires-recent-login' => 'For security, please sign in again and retry.',
    _ => 'Something went wrong (${error.code}). Please try again.',
  };
}
