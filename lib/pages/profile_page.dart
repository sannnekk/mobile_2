import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/widgets/shared/noo_logout_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Имя пользователя',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'email@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Profile options
        Text(
          'Настройки',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        // Profile menu items would go here
        Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onSurface,
                ),
                title: const Text('Личные данные'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onTap: () {
                  // Navigate to personal data page
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: const Text('Уведомления'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onTap: () {
                  // Navigate to notifications page
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // Logout button
        const NooLogoutButton(),
        const SizedBox(height: 16),
      ],
    );
  }
}
