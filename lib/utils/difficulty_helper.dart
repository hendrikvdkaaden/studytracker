import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_colors.dart';
import 'l10n_extension.dart';

class DifficultyHelper {
  static String getLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.veryHard:
        return 'Very Hard';
    }
  }

  static Color getColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green.shade100;
      case Difficulty.medium:
        return Colors.yellow.shade100;
      case Difficulty.hard:
        return Colors.red.shade100;
      case Difficulty.veryHard:
        return Colors.red.shade100;
    }
  }

  static Color getAccentColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.completed;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.overdue;
      case Difficulty.veryHard:
        return AppColors.iconPurple;
    }
  }

  static String getLocalizedLabel(BuildContext context, Difficulty difficulty) {
    final l10n = context.l10n;
    switch (difficulty) {
      case Difficulty.easy:
        return l10n.difficultyEasy;
      case Difficulty.medium:
        return l10n.difficultyMedium;
      case Difficulty.hard:
        return l10n.difficultyHard;
      case Difficulty.veryHard:
        return l10n.difficultyVeryHard;
    }
  }
}
