import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../utils/difficulty_helper.dart';

class DifficultyItem extends StatelessWidget {
  final Difficulty difficulty;

  const DifficultyItem({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: DifficultyHelper.getAccentColor(difficulty),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(DifficultyHelper.getLabel(difficulty)),
      ],
    );
  }
}
