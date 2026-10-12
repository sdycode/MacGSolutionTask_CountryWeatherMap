import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/auth_layout.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/auth_form_state.dart';
import '../cubit/sign_up_cubit.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignUpCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    context.read<SignUpCubit>().signUp(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, AuthFormState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == FormStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message ?? '')));
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return AuthLayout(
          appBar: AppBar(),
          children: [
            const AuthHeader(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Create account',
              subtitle: "We'll send you a link to verify your email.",
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: validateNewPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText:
                          'At least 8 characters with a letter and a number',
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signUp(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create account',
              isLoading: isLoading,
              onPressed: _signUp,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
