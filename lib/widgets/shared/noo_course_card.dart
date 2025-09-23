import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_subject.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';
import 'package:mobile_2/widgets/shared/noo_uploaded_image.dart';

typedef CourseAction = ({String label, IconData icon, VoidCallback onPressed});

class NooCourseCard extends StatelessWidget {
  final CourseEntity course;
  final bool isPinned;
  final List<CourseAction> actions;

  const NooCourseCard({
    super.key,
    required this.course,
    this.isPinned = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              NooUploadedImage(
                media: course.images.firstOrNull,
                fit: BoxFit.cover,
                aspectRatio: 1.5848,
              ),
              if (isPinned)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Subject
        NooSubject(subject: course.subject),

        const SizedBox(height: 4),

        // Course name
        NooTextTitle(course.name, size: NooTitleSize.medium),

        const SizedBox(height: 4),

        // Course description
        if (course.description != null)
          Text(
            course.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 8),
      ],
    );

    return GestureDetector(
      onTap: () => _onCardTap(context),
      onLongPress: () => _showActionsMenu(context),
      child: NooCard(child: cardContent),
    );
  }

  void _onCardTap(BuildContext context) {
    // Navigate to course details page with slug
    // The CourseDetailsRoute class ensures type safety for the route definition
    context.go('/course/${course.slug}');
  }

  void _showActionsMenu(BuildContext context) {
    if (actions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          return ListTile(
            leading: Icon(action.icon),
            title: Text(action.label),
            onTap: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
          );
        }).toList(),
      ),
    );
  }
}
