import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';
import '../../utils/goal_type_helper.dart';
import '../../utils/difficulty_helper.dart';
import 'info_card.dart';
import 'study_time_card.dart';

class GoalInfoList extends StatelessWidget {
  final Goal goal;
  final Color color;

  const GoalInfoList({
    super.key,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      InfoCard(
        icon: Icons.book,
        label: 'Subject',
        value: goal.subject,
        color: Colors.purple,
      ),
      InfoCard(
        icon: GoalTypeHelper.getIconForType(goal.type),
        label: 'Type',
        value: GoalTypeHelper.getLabel(goal.type),
        color: Colors.blue,
      ),
      InfoCard(
        icon: Icons.flag,
        label: 'Difficulty',
        value: DifficultyHelper.getLabel(goal.difficulty),
        color: DifficultyHelper.getColor(goal.difficulty),
      ),
      InfoCard(
        icon: Icons.event,
        label: 'Deadline',
        value: DateFormat('EEEE, d MMMM yyyy').format(goal.date),
        color: color,
      ),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        ),
        if (goal.studyTime > 0) ...[
          const SizedBox(height: 12),
          StudyTimeCard(goal: goal),
        ],
      ],
    );
  }
}
