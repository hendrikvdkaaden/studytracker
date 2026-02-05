import 'package:flutter/material.dart';
import '../../../models/goal.dart';

class GoalTypeSelector extends StatelessWidget {
  final GoalType selectedType;
  final ValueChanged<GoalType> onTypeSelected;

  const GoalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalType.values.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => onTypeSelected(type),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF135BEC)
                      : isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForType(type),
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white
                              : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getDisplayNameForType(type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForType(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return Icons.school;
      case GoalType.test:
        return Icons.track_changes;
      case GoalType.assignment:
        return Icons.description;
      case GoalType.presentation:
        return Icons.show_chart;
      case GoalType.project:
        return Icons.code;
      case GoalType.paper:
        return Icons.note;
      case GoalType.quiz:
        return Icons.quiz;
      case GoalType.other:
        return Icons.book;
    }
  }

  String _getDisplayNameForType(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return 'Exam';
      case GoalType.test:
        return 'Test';
      case GoalType.assignment:
        return 'Assignment';
      case GoalType.presentation:
        return 'Presentation';
      case GoalType.project:
        return 'Project';
      case GoalType.paper:
        return 'Paper';
      case GoalType.quiz:
        return 'Quiz';
      case GoalType.other:
        return 'Book';
    }
  }
}
