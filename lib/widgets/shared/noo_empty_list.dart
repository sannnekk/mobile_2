import 'package:flutter/material.dart';
import 'noo_text.dart';
import 'noo_text_title.dart';

class NooEmptyList extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? message;

  const NooEmptyList({super.key, this.child, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              NooTextTitle(title!),
              const SizedBox(height: 8),
            ],
            if (message != null) ...[
              NooText(message!, align: TextAlign.center),
              const SizedBox(height: 16),
            ],
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
