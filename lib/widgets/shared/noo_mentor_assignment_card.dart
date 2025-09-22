import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_subject.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_user_avatar.dart';

class NooMentorAssignmentCard extends StatelessWidget {
  final MentorAssignmentEntity assignment;

  const NooMentorAssignmentCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final mentor = assignment.mentor;
    final subject = assignment.subject;

    return NooCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mentor info
          if (mentor != null) ...[
            Row(
              children: [
                NooUserAvatar(user: mentor, avatar: mentor.avatar, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NooTextTitle(mentor.name, size: NooTitleSize.small),
                      if (mentor.email.isNotEmpty)
                        Text(
                          mentor.email,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Assignment details
          NooText('Куратор по предмету:', dimmed: true),

          // Subject info
          if (subject != null) ...[
            const SizedBox(height: 6),
            NooSubject(subject: subject),
          ],
        ],
      ),
    );
  }
}
