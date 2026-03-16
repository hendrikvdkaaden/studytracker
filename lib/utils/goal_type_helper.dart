import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'l10n_extension.dart';

class GoalTypeHelper {
  static IconData getIconForType(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return Icons.school;
      case GoalType.test:
        return Icons.quiz;
      case GoalType.assignment:
        return Icons.assignment;
      case GoalType.presentation:
        return Icons.present_to_all;
      case GoalType.project:
        return Icons.work;
      case GoalType.paper:
        return Icons.description;
      case GoalType.quiz:
        return Icons.question_answer;
      case GoalType.other:
        return Icons.more_horiz;
    }
  }

  static String getLabel(GoalType type) {
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
        return 'Other';
    }
  }

  static String getLocalizedLabel(BuildContext context, GoalType type) {
    final l10n = context.l10n;
    switch (type) {
      case GoalType.exam:
        return l10n.goalTypeExam;
      case GoalType.test:
        return l10n.goalTypeTest;
      case GoalType.assignment:
        return l10n.goalTypeAssignment;
      case GoalType.presentation:
        return l10n.goalTypePresentation;
      case GoalType.project:
        return l10n.goalTypeProject;
      case GoalType.paper:
        return l10n.goalTypePaper;
      case GoalType.quiz:
        return l10n.goalTypeQuiz;
      case GoalType.other:
        return l10n.goalTypeOther;
    }
  }
}
