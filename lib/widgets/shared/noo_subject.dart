import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/subject.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';

class NooSubject extends StatelessWidget {
  final SubjectEntity? subject;

  const NooSubject({super.key, this.subject});

  @override
  Widget build(BuildContext context) {
    if (subject == null) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: subject!.color,
            shape: BoxShape.rectangle,
          ),
        ),
        const SizedBox(width: 4),
        NooText(subject!.name),
      ],
    );
  }
}
