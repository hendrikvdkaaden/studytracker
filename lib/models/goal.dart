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

  // Field 5 held a Difficulty. The feature is gone, but the enum below and
  // its adapter must stay registered: Hive throws when it decodes a value
  // whose typeId is unknown, and existing records still carry one there.
  // Field 5 must never be reused.

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int studyTime; // in minutes

  /// Identifier of the matching event in the user's calendar, when calendar
  /// sync is on. Null when the goal was never synced.
  @HiveField(8)
  String? calendarEventId;

  Goal({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.type,
    this.isCompleted = false,
    this.studyTime = 0,
    this.calendarEventId,
  });

  // Helper methods
  bool isOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(date.year, date.month, date.day);
    return !isCompleted && deadlineDay.isBefore(today);
  }

  int daysUntilDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(date.year, date.month, date.day);
    return deadlineDay.difference(today).inDays;
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
    bool? isCompleted,
    int? studyTime,
    String? calendarEventId,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      studyTime: studyTime ?? this.studyTime,
      calendarEventId: calendarEventId ?? this.calendarEventId,
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

/// Retained only so Hive can decode field 5 of goals written before the
/// difficulty feature was removed. Not used anywhere in the app.
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
