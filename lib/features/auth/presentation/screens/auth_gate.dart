import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../countries/presentation/screens/countries_screen.dart';
import '../cubit/auth_cubit.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => switch (state) {
        AuthUnknown() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        Unauthenticated() => const LoginScreen(),
        Authenticated(:final user)
            when !user.isAnonymous && !user.emailVerified =>
          const VerifyEmailScreen(),
        Authenticated() => const CountriesScreen(),
      },
    );
  }
}
