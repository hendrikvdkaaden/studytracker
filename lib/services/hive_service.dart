import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';
import '../models/study_session.dart';

/// Service for managing Hive database initialization and boxes
class HiveService {
  // Box names
  static const String goalsBoxName = 'goals';
  static const String studySessionsBoxName = 'study_sessions';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all type adapters
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(DifficultyAdapter());
    Hive.registerAdapter(StudySessionAdapter());

    // Open all boxes
    await Hive.openBox<Goal>(goalsBoxName);
    await Hive.openBox<StudySession>(studySessionsBoxName);

    // Run migration for existing study sessions
    await _migrateStudySessions();
  }

  /// Migrate existing study sessions to mark them as completed
  static Future<void> _migrateStudySessions() async {
    final box = getStudySessionsBox();
    bool needsMigration = false;

    // Check if any session doesn't have the isCompleted field set properly
    for (var session in box.values) {
      // If startTime or notes are null and this looks like an old session,
      // we can assume it's a completed session from before the migration
      if (session.startTime == null && session.notes == null) {
        needsMigration = true;
        break;
      }
    }

    if (needsMigration) {
      debugPrint('Migrating study sessions...');
      for (var session in box.values.toList()) {
        // Only migrate if it looks like an old session
        if (session.startTime == null && session.notes == null) {
          final migratedSession = session.copyWith(
            isCompleted: true,
          );
          await box.put(session.id, migratedSession);
        }
      }
      debugPrint('Migration completed: ${box.length} sessions processed');
    }
  }

  /// Get the goals box
  static Box<Goal> getGoalsBox() {
    return Hive.box<Goal>(goalsBoxName);
  }

  /// Get the study sessions box
  static Box<StudySession> getStudySessionsBox() {
    return Hive.box<StudySession>(studySessionsBoxName);
  }

  /// Close all boxes (call this when app is disposed)
  static Future<void> closeBoxes() async {
    await Hive.box<Goal>(goalsBoxName).close();
    await Hive.box<StudySession>(studySessionsBoxName).close();
  }

  /// Clear all data (useful for testing or reset functionality)
  static Future<void> clearAllData() async {
    await Hive.box<Goal>(goalsBoxName).clear();
    await Hive.box<StudySession>(studySessionsBoxName).clear();
  }
}
