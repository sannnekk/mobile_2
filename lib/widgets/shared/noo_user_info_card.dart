import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/utils/role_helpers.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';

class NooUserInfoCard extends StatelessWidget {
  final UserEntity user;

  const NooUserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Name
        Text(
          user.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Username
        NooText(user.username, align: TextAlign.center),
        const SizedBox(height: 4),

        // Email
        NooText(user.email, dimmed: true, align: TextAlign.center),
        const SizedBox(height: 8),

        // Role
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            getRoleDisplayName(user.role),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
