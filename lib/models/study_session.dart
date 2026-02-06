import 'package:hive/hive.dart';

part 'study_session.g.dart';

/// A study session that tracks time spent studying for a goal.
/// Can be either planned (isCompleted = false) or completed (isCompleted = true).
@HiveType(typeId: 3)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String goalId;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  int duration;
  @HiveField(4)
  bool isCompleted;
  @HiveField(5)
  DateTime? startTime;
  @HiveField(6)
  String? notes;
  @HiveField(7)
  int? actualDuration;

  StudySession({
    required this.id,
    required this.goalId,
    required this.date,
    required this.duration,
    this.isCompleted = true,
    this.startTime,
    this.notes,
    this.actualDuration,
  });

  /// Returns the duration as a formatted string (e.g., "1h 30m")
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  StudySession copyWith({
    String? id,
    String? goalId,
    DateTime? date,
    int? duration,
    bool? isCompleted,
    DateTime? startTime,
    String? notes,
    int? actualDuration,
  }) {
    return StudySession(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      notes: notes ?? this.notes,
      actualDuration: actualDuration ?? this.actualDuration,
    );
  }
}
