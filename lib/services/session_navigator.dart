import 'package:flutter/material.dart';

import '../product/screens/study_timer_screen.dart';
import 'goal_repository.dart';
import 'study_session_repository.dart';

/// Opens the timer for a session tapped in a notification.
///
/// A notification carries only an id, so the session and its goal have to be
/// looked up; either may be gone by the time the reminder is tapped, in which
/// case nothing happens and the app opens where it normally would.
class SessionNavigator {
  /// Attached to MaterialApp so a notification tap can navigate without a
  /// BuildContext of its own.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// A session tapped before the app had a navigator, waiting to be opened.
  static String? _pendingSessionId;

  /// Opens the timer for [sessionId], or remembers it when the app is not
  /// ready to navigate yet.
  static void openSession(String sessionId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingSessionId = sessionId;
      return;
    }
    _push(navigator, sessionId);
  }

  /// Opens whatever was tapped while the app was still starting.
  ///
  /// Called once the first screen is up, since a tap that launched the app
  /// arrives long before there is anything to push a route onto.
  static void openPending() {
    final sessionId = _pendingSessionId;
    if (sessionId == null) return;
    _pendingSessionId = null;
    openSession(sessionId);
  }

  /// Remembers a session to open as soon as the app is ready.
  static void setPending(String sessionId) => _pendingSessionId = sessionId;

  static void _push(NavigatorState navigator, String sessionId) {
    final session = StudySessionRepository().getSessionById(sessionId);
    if (session == null) return;

    final goal = GoalRepository().getGoalById(session.goalId);
    if (goal == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => StudyTimerScreen(session: session, goal: goal),
      ),
    );
  }
}
