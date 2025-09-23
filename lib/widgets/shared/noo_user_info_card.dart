import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/core/utils/role_helpers.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_user_avatar.dart';

class NooUserInfoCard extends StatelessWidget {
  final UserEntity user;
  final bool compact;

  const NooUserInfoCard({super.key, required this.user, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return NooCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar
            NooUserAvatar(user: user, radius: 40),
            const SizedBox(width: 12),

            // Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NooTextTitle(user.name, size: NooTitleSize.small),
                const SizedBox(height: 4),

                // Username
                NooText(user.username, dimmed: true),
                const SizedBox(height: 2),

                // Email
                NooText(user.email, dimmed: true),
              ],
            ),
          ],
        ),
      );
    }

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
