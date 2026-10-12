import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/section_card.dart';
import '../cubit/account_cubit.dart';
import '../cubit/auth_cubit.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AccountCubit>(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  Future<void> _signOut(BuildContext context, bool isGuest) async {
    final cubit = context.read<AccountCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: isGuest
          ? "Guest sessions can't be restored. Signing out ends this guest "
                'session for good and clears favorites and recent searches on '
                'this device.'
          : 'Favorites and recent searches on this device will be cleared. '
                'You can sign in again any time.',
      confirmLabel: 'Sign out',
    );
    if (confirmed) cubit.signOut();
  }

  Future<void> _deleteAccount(BuildContext context, bool isGuest) async {
    final cubit = context.read<AccountCubit>();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteAccountDialog(askPassword: !isGuest),
    );
    if (password != null) cubit.deleteAccount(password: password);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isGuest = user?.isAnonymous ?? true;
    final createdAt = user?.createdAt;

    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);

        if (state.isDone) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state.message != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Account')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                isGuest ? Icons.person_outline : Icons.person,
                                size: 36,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isGuest ? 'Guest user' : (user?.email ?? ''),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              avatar: Icon(
                                isGuest
                                    ? Icons.timer_outlined
                                    : Icons.verified_outlined,
                                size: 18,
                              ),
                              label: Text(
                                isGuest ? 'Guest session' : 'Email verified',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Details',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Signed in with',
                            value: isGuest
                                ? 'Guest (anonymous)'
                                : 'Email & password',
                          ),
                          if (createdAt != null)
                            _InfoRow(
                              label: 'Member since',
                              value: _formatDate(createdAt),
                            ),
                          if (isGuest) ...[
                            const Divider(height: 24),
                            Text(
                              'Guest data only lives on this device. Create an '
                              'account to keep using the app after signing out.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: state.isBusy
                            ? null
                            : () => _signOut(context, isGuest),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: TextButton.icon(
                        onPressed: state.isBusy
                            ? null
                            : () => _deleteAccount(context, isGuest),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_forever_outlined),
                        label: const Text('Delete account'),
                      ),
                    ),
                    if (state.isBusy)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.askPassword});

  final bool askPassword;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (widget.askPassword && _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your password to confirm');
      return;
    }
    Navigator.of(context).pop(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your account and clears favorites and '
            "recent searches on this device. This can't be undone.",
          ),
          if (widget.askPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => _confirm(),
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _confirm,
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
