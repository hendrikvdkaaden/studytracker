import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subject;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  GoalType type;

  @HiveField(5)
  Difficulty difficulty;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int studyTime; // in minutes

  Goal({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.type,
    required this.difficulty,
    this.isCompleted = false,
    this.studyTime = 0,
  });

  // Helper methods
  bool isOverdue() {
    return !isCompleted && date.isBefore(DateTime.now());
  }

  int daysUntilDeadline() {
    return date.difference(DateTime.now()).inDays;
  }

  // Helper methods for study time
  String getFormattedStudyTime() {
    final hours = studyTime ~/ 60;
    final minutes = studyTime % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  // CopyWith method voor immutability
  Goal copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? date,
    GoalType? type,
    Difficulty? difficulty,
    bool? isCompleted,
    int? studyTime,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      studyTime: studyTime ?? this.studyTime,
    );
  }
}

@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0)
  exam,

  @HiveField(1)
  test,

  @HiveField(2)
  assignment,

  @HiveField(3)
  presentation,

  @HiveField(4)
  project,

  @HiveField(5)
  paper,

  @HiveField(6)
  quiz,

  @HiveField(7)
  other,
}

@HiveType(typeId: 2)
enum Difficulty {
  @HiveField(0)
  easy,

  @HiveField(1)
  medium,

  @HiveField(2)
  hard,

  @HiveField(3)
  veryHard,
}
