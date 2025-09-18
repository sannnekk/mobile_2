import 'package:flutter/material.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';

class AssignedWorksPage extends StatelessWidget {
  const AssignedWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(
      length: 5,
      vsync: Scaffold.of(context),
    );

    return Column(
      children: [
        NooTabBar(
          controller: tabController,
          tabs: const [
            Text('Все'),
            Text('Нерешенные'),
            Text('Непроверенные'),
            Text('Проверенные'),
            Text('Архив'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              Center(child: Text('Все работы')),
              Center(child: Text('Нерешенные работы')),
              Center(child: Text('Непроверенные работы')),
              Center(child: Text('Проверенные работы')),
              Center(child: Text('Архивированные работы')),
            ],
          ),
        ),
      ],
    );
  }
}
