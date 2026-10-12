import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/auth_layout.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/verify_email_cubit.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VerifyEmailCubit>(),
      child: const _VerifyEmailView(),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView();

  Future<void> _startOver(BuildContext context) async {
    final cubit = context.read<VerifyEmailCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Use a different email?',
      message:
          'This removes the unverified account so you can sign up again '
          'with the right email.',
      confirmLabel: 'Start over',
      isDestructive: true,
    );
    if (confirmed) cubit.startOver();
  }

  Future<void> _signOut(BuildContext context) async {
    final cubit = context.read<VerifyEmailCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: 'You can sign in again later to finish verifying your email.',
      confirmLabel: 'Sign out',
    );
    if (confirmed) cubit.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final email = authState is Authenticated
        ? authState.user.email ?? 'your email'
        : 'your email';

    return BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        final cubit = context.read<VerifyEmailCubit>();

        return AuthLayout(
          children: [
            AuthHeader(
              icon: Icons.mark_email_unread_outlined,
              title: 'Verify your email',
              subtitle:
                  'We sent a verification link to $email. Open it to activate '
                  'your account.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This screen moves on by itself once you've verified. "
                      "Can't find the email? Check your spam folder.",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: "I've verified my email",
              isLoading: state.isChecking,
              onPressed: state.isLeaving ? null : cubit.checkNow,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: state.resendCooldown > 0 || state.isLeaving
                    ? null
                    : cubit.resend,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  state.resendCooldown > 0
                      ? 'Resend email in ${state.resendCooldown}s'
                      : 'Resend email',
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: state.isLeaving ? null : () => _startOver(context),
              child: const Text('Wrong email? Start over'),
            ),
            TextButton(
              onPressed: state.isLeaving ? null : () => _signOut(context),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );
  }
}
