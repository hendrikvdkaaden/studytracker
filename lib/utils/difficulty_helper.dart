import 'package:flutter/material.dart';
import '../models/goal.dart';

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
        return Colors.green;
      case Difficulty.medium:
        return Colors.yellow;
      case Difficulty.hard:
        return Colors.orange;
      case Difficulty.veryHard:
        return Colors.red;
    }
  }
}
