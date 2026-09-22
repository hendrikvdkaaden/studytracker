import 'dart:io';

import 'package:deadly/models/goal.dart';
import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/study_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Which list a session belongs to once the timer has been stopped early.
///
/// The bug: stopping the timer near the end of a session leaves it open so it
/// can be resumed, but the planned/completed split read `isCompleted`
/// directly. A user who studied 55 of 60 minutes saw that session listed as an
/// outstanding plan forever, and it never appeared among the completed ones --
/// the only escape was reaching the exact target.
void main() {
  late Directory tempDir;
  late Box<StudySession> box;
  late StudySessionRepository repo;

  StudySession session({
    required String id,
    int duration = 60,
    int? actualDuration,
    bool isCompleted = false,
  }) =>
      StudySession(
        id: id,
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: duration,
        isCompleted: isCompleted,
        actualDuration: actualDuration,
      );

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GoalAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GoalTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DifficultyAdapter());
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StudySessionAdapter());
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('session_partition_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Goal>('goals');
    box = await Hive.openBox<StudySession>('study_sessions');
    repo = StudySessionRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  List<String> idsOf(List<StudySession> sessions) =>
      sessions.map((s) => s.id).toList();

  group('a session stopped near the end', () {
    setUp(() async {
      // 55 of 60 minutes: stopped, still open, still resumable.
      await box.put('nearly', session(id: 'nearly', actualDuration: 55));
    });

    test('leaves the planned list', () async {
      expect(idsOf(repo.getPlannedSessionsByGoalId('g1')), isEmpty);
      expect(idsOf(repo.getAllPlannedSessions()), isEmpty);
    });

    test('appears among the completed ones', () async {
      expect(idsOf(repo.getCompletedSessionsByGoalId('g1')), ['nearly']);
    });
  });

  group('a session genuinely abandoned', () {
    setUp(() async {
      await box.put('barely', session(id: 'barely', actualDuration: 5));
    });

    test('stays in the planned list so it can be resumed', () async {
      expect(idsOf(repo.getPlannedSessionsByGoalId('g1')), ['barely']);
      expect(idsOf(repo.getAllPlannedSessions()), ['barely']);
    });

    test('is not reported as completed', () async {
      expect(idsOf(repo.getCompletedSessionsByGoalId('g1')), isEmpty);
    });
  });

  test('an untouched plan is still planned', () async {
    await box.put('fresh', session(id: 'fresh'));

    expect(idsOf(repo.getPlannedSessionsByGoalId('g1')), ['fresh']);
    expect(idsOf(repo.getCompletedSessionsByGoalId('g1')), isEmpty);
  });

  test('a finished session is still completed', () async {
    await box.put(
      'done',
      session(id: 'done', actualDuration: 60, isCompleted: true),
    );

    expect(idsOf(repo.getCompletedSessionsByGoalId('g1')), ['done']);
    expect(idsOf(repo.getPlannedSessionsByGoalId('g1')), isEmpty);
  });

  test('every session lands in exactly one of the two lists', () async {
    await box.putAll({
      'fresh': session(id: 'fresh'),
      'barely': session(id: 'barely', actualDuration: 5),
      'nearly': session(id: 'nearly', actualDuration: 55),
      'done': session(id: 'done', actualDuration: 60, isCompleted: true),
    });

    final planned = idsOf(repo.getPlannedSessionsByGoalId('g1')).toSet();
    final completed = idsOf(repo.getCompletedSessionsByGoalId('g1')).toSet();

    expect(planned.intersection(completed), isEmpty,
        reason: 'no session may appear in both');
    expect(planned.union(completed),
        {'fresh', 'barely', 'nearly', 'done'},
        reason: 'no session may fall through the gap');
  });
}
