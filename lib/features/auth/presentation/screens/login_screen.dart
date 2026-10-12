import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/auth_layout.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/auth_form_state.dart';
import '../cubit/login_cubit.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().signIn(
      _emailController.text,
      _passwordController.text,
    );
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().continueAsGuest();
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ForgotPasswordScreen(initialEmail: _emailController.text.trim()),
      ),
    );
  }

  void _openSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LoginCubit, AuthFormState>(
      listenWhen: (previous, current) => current.status == FormStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message ?? '')));
      },
      builder: (context, state) {
        final isBusy = state.isLoading;
        final isSigningIn = isBusy && !state.isGuest;
        final isGuestLoading = isBusy && state.isGuest;

        return AuthLayout(
          children: [
            const AuthHeader(
              icon: Icons.public,
              title: 'Welcome back',
              subtitle: 'Sign in to explore countries, weather and maps.',
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: validatePassword,
                    onFieldSubmitted: (_) => _signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: ExcludeFocus(
                        child: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isBusy ? null : _openForgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Sign in',
              isLoading: isSigningIn,
              onPressed: isBusy ? null : _signIn,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _continueAsGuest,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isGuestLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_outline),
                label: const Text('Continue as guest'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: isBusy ? null : _openSignUp,
                  child: const Text('Create one'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
