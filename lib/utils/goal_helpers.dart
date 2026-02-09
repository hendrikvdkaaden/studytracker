import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalHelpers {
  static IconData getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return Icons.menu_book;
      case GoalType.assignment:
        return Icons.edit_note;
      case GoalType.project:
        return Icons.lightbulb_outline;
      case GoalType.presentation:
        return Icons.slideshow;
      case GoalType.test:
        return Icons.quiz;
      case GoalType.paper:
        return Icons.description;
      case GoalType.quiz:
        return Icons.help_outline;
      case GoalType.other:
        return Icons.event_note;
    }
  }

  static MaterialColor getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return Colors.blue;
      case GoalType.assignment:
        return Colors.indigo;
      case GoalType.project:
        return Colors.purple;
      case GoalType.presentation:
        return Colors.orange;
      case GoalType.test:
        return Colors.teal;
      case GoalType.paper:
        return Colors.cyan;
      case GoalType.quiz:
        return Colors.pink;
      case GoalType.other:
        return Colors.grey;
    }
  }

  static String getGoalTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return 'Exam';
      case GoalType.assignment:
        return 'Assignment';
      case GoalType.project:
        return 'Project';
      case GoalType.presentation:
        return 'Presentation';
      case GoalType.test:
        return 'Test';
      case GoalType.paper:
        return 'Paper';
      case GoalType.quiz:
        return 'Quiz';
      case GoalType.other:
        return 'Other';
    }
  }
}
