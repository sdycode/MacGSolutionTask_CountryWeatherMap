import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/auth_layout.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/auth_form_state.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: _ForgotPasswordView(initialEmail: initialEmail),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );

  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordCubit>().sendResetLink(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, AuthFormState>(
      listenWhen: (previous, current) => current.status == FormStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message ?? '')));
      },
      builder: (context, state) {
        if (state.status == FormStatus.success) {
          return AuthLayout(
            appBar: AppBar(),
            children: [
              AuthHeader(
                icon: Icons.mark_email_read_outlined,
                title: 'Check your inbox',
                subtitle:
                    'If an account exists for ${_emailController.text.trim()}, '
                    "we've sent a link to reset your password. Check your spam "
                    'folder too.',
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Back to sign in',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: context.read<ForgotPasswordCubit>().reset,
                child: const Text('Use a different email'),
              ),
            ],
          );
        }

        return AuthLayout(
          appBar: AppBar(),
          children: [
            const AuthHeader(
              icon: Icons.lock_reset,
              title: 'Reset password',
              subtitle:
                  "Enter your account email and we'll send you a link to set a "
                  'new password.',
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: validateEmail,
                onFieldSubmitted: (_) => _sendResetLink(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Send reset link',
              isLoading: state.isLoading,
              onPressed: _sendResetLink,
            ),
          ],
        );
      },
    );
  }
}
