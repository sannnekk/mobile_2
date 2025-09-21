import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class AssignedWorkDetailPage extends StatelessWidget {
  final String workId;

  const AssignedWorkDetailPage({super.key, required this.workId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: NooTextTitle('Работа', size: NooTitleSize.small),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/assigned_works'),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: NooTextTitle(
              'Детали работы с ID: $workId',
              size: NooTitleSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
