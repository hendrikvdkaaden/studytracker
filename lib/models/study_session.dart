import 'package:hive/hive.dart';

part 'study_session.g.dart';

/// A study session that tracks time spent studying for a goal.
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

  StudySession({
    required this.id,
    required this.goalId,
    required this.date,
    required this.duration,
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
  }) {
    return StudySession(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      duration: duration ?? this.duration,
    );
  }
}
