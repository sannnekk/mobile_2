import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/work.dart';
import 'package:mobile_2/core/utils/task_criteria.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class NooTaskCriteria extends StatelessWidget {
  final WorkTaskType taskType;
  final Map<String, int>? detailedScore;

  const NooTaskCriteria({
    super.key,
    required this.taskType,
    this.detailedScore = const {},
  });

  int? getScore(String code) {
    return detailedScore?[code];
  }

  @override
  Widget build(BuildContext context) {
    List<Criterium> criteria = [];

    if (taskType == WorkTaskType.essay) {
      criteria = TaskCriteria.essayCriteria;
    } else if (taskType == WorkTaskType.finalEssay) {
      criteria = TaskCriteria.finalEssayCriteria;
    } else if (taskType == WorkTaskType.dictation) {
      criteria = TaskCriteria.dictationCriteria;
    }

    if (criteria.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...criteria.map(
          (criterium) => NooCard(
            padding: const EdgeInsets.all(0),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: NooTextTitle(
                      criterium.name,
                      size: NooTitleSize.small,
                      isBold: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: NooText(
                      getScore(criterium.code) == null
                          ? 'макс. ${criterium.maxScore}'
                          : '${getScore(criterium.code)}/${criterium.maxScore}',
                      dimmed: false,
                    ),
                  ),
                ],
              ),
              children: [
                if (criterium.description != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: NooText(
                      criterium.description!,
                      align: TextAlign.left,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
