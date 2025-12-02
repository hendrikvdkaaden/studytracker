import 'package:flutter/material.dart';
import '../../models/goal.dart';
import 'difficulty_item.dart';

class DifficultyDropdown extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onChanged;

  const DifficultyDropdown({
    super.key,
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Difficulty>(
      value: selectedDifficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.trending_up),
      ),
      items: Difficulty.values.map((difficulty) {
        return DropdownMenuItem(
          value: difficulty,
          child: DifficultyItem(difficulty: difficulty),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
