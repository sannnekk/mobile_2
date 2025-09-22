import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/widgets/shared/noo_uploaded_image.dart';

class NooUserAvatar extends StatelessWidget {
  final UserEntity user;
  final double radius;
  final UserAvatarEntity? avatar;

  const NooUserAvatar({
    super.key,
    required this.user,
    this.radius = 50,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // For now, use a simple implementation
    // TODO: Integrate with UserAvatarEntity when available
    if (avatar != null) {
      if (avatar!.avatarType == AvatarType.telegram &&
          avatar!.telegramAvatarUrl.isNotEmpty) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: ClipOval(
            child: Image.network(
              avatar!.telegramAvatarUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: radius,
                  color: theme.colorScheme.primary,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Icon(
                  Icons.person,
                  size: radius,
                  color: theme.colorScheme.primary,
                );
              },
            ),
          ),
        );
      } else if (avatar!.avatarType == AvatarType.custom &&
          avatar!.media != null) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: ClipOval(
            child: NooUploadedImage(
              media: avatar?.media,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    // Default avatar with initials
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
