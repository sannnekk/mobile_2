import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_providers.dart';
import 'noo_button.dart';

class NooLogoutButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const NooLogoutButton({super.key, this.onPressed, this.loading = false});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    if (onPressed != null) {
      onPressed!();
    } else {
      // Clear all user authentication data
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.logout();

      // Navigate to auth page
      if (context.mounted) {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return NooButton(
      label: 'Выйти',
      onPressed: () => _handleLogout(context, ref),
      style: NooButtonStyle.danger,
      loading: loading || authState.isLoading,
    );
  }
}
