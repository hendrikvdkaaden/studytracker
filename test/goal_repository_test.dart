import 'dart:io';

import 'package:deadly/models/goal.dart';
import 'package:deadly/services/goal_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Builds a goal due on [day] at [hour], defaulting to the 12:00 the app
/// assigns to new deadlines.
Goal _goalDueAt(DateTime day, {int hour = 12, bool isCompleted = false}) {
  return Goal(
    id: 'goal-${day.toIso8601String()}-$hour',
    title: 'Test goal',
    subject: 'Math',
    date: DateTime(day.year, day.month, day.day, hour),
    type: GoalType.exam,
    isCompleted: isCompleted,
    studyTime: 60,
  );
}

void main() {
  late Directory tempDir;
  late Box<Goal> box;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GoalAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GoalTypeAdapter());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('goal_repo_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Goal>('goals');
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('getUpcomingGoals', () {
    test('includes a goal due today whose time of day has already passed', () async {
      // Regression: a deadline set for today at 12:00 used to disappear from
      // the dashboard after 12:00 — not overdue (the day is not over) but no
      // longer "after now" either, so it landed in neither section.
      final today = DateTime.now();
      final goal = _goalDueAt(today, hour: 0);
      await box.put(goal.id, goal);

      final upcoming = GoalRepository().getUpcomingGoals(30);

      expect(upcoming.map((g) => g.id), contains(goal.id));
      expect(goal.isOverdue(), isFalse,
          reason: 'a goal due today is not overdue until the day is over');
    });

    test('excludes goals whose deadline day has passed', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final goal = _goalDueAt(yesterday);
      await box.put(goal.id, goal);

      expect(GoalRepository().getUpcomingGoals(30), isEmpty);
      expect(goal.isOverdue(), isTrue);
    });

    test('excludes completed goals', () async {
      final goal = _goalDueAt(DateTime.now(), isCompleted: true);
      await box.put(goal.id, goal);

      expect(GoalRepository().getUpcomingGoals(30), isEmpty);
    });

    test('includes the last day of the window and excludes the day after', () async {
      final today = DateTime.now();
      final onBoundary = _goalDueAt(today.add(const Duration(days: 7)));
      final pastBoundary = _goalDueAt(today.add(const Duration(days: 8)));
      await box.put(onBoundary.id, onBoundary);
      await box.put(pastBoundary.id, pastBoundary);

      final ids = GoalRepository().getUpcomingGoals(7).map((g) => g.id);

      expect(ids, contains(onBoundary.id));
      expect(ids, isNot(contains(pastBoundary.id)));
    });

    test('every incomplete goal is either upcoming or overdue, never neither', () async {
      // The two categories must stay exact complements within the window.
      final today = DateTime.now();
      final goals = [
        _goalDueAt(today, hour: 0),
        _goalDueAt(today, hour: 12),
        _goalDueAt(today, hour: 23),
        _goalDueAt(today.subtract(const Duration(days: 1))),
        _goalDueAt(today.add(const Duration(days: 3))),
      ];
      for (final g in goals) {
        await box.put(g.id, g);
      }

      final repo = GoalRepository();
      final upcomingIds = repo.getUpcomingGoals(30).map((g) => g.id).toSet();
      final overdueIds = repo.getOverdueGoals().map((g) => g.id).toSet();

      for (final g in goals) {
        expect(
          upcomingIds.contains(g.id) || overdueIds.contains(g.id),
          isTrue,
          reason: 'goal due ${g.date} appears in neither section',
        );
        expect(upcomingIds.intersection(overdueIds), isEmpty,
            reason: 'a goal must not be both upcoming and overdue');
      }
    });
  });
}
