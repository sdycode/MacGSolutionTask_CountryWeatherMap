final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Please enter your email';
  if (!_emailRegex.hasMatch(email)) return 'Please enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a password';
  if (value.length < 8) return 'Use at least 8 characters';
  if (!value.contains(RegExp(r'[A-Za-z]')) ||
      !value.contains(RegExp(r'[0-9]'))) {
    return 'Use at least one letter and one number';
  }
  return null;
}
