import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/study_session_repository.dart';
import '../../widgets/study_timer/timer_controls.dart';
import '../templates/study_timer_template.dart';

class StudyTimerScreen extends StatefulWidget {
  final StudySession session;
  final Goal goal;

  const StudyTimerScreen({
    super.key,
    required this.session,
    required this.goal,
  });

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  final StudySessionRepository _sessionRepo = StudySessionRepository();
  Timer? _timer;
  int _elapsedSeconds = 0;
  TimerState _timerState = TimerState.initial;

  @override
  void initState() {
    super.initState();
    // Load existing actualDuration if available
    if (widget.session.actualDuration != null) {
      _elapsedSeconds = widget.session.actualDuration! * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerState = TimerState.running;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  Future<void> _stopTimer() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Session?'),
        content: Text(
          'You studied for ${_formatElapsedTime()}. Save this session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _timer?.cancel();
      // Update session with actual time spent
      // Only mark as completed if time was actually logged
      final actualMinutes = _elapsedSeconds ~/ 60;
      final updatedSession = widget.session.copyWith(
        actualDuration: actualMinutes,
      );

      await _sessionRepo.updateSession(updatedSession);

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session saved! ${_formatElapsedTime()} logged.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleBack() async {
    if (_timerState == TimerState.running || _timerState == TimerState.paused) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit Timer?'),
          content: const Text(
            'Your session is still running. Are you sure you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        _timer?.cancel();
        if (mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeSession() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete?'),
        content: const Text(
          'Mark this session as fully completed? The full session duration will be logged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _timer?.cancel();

      // Mark session as completed with full duration
      final updatedSession = widget.session.copyWith(
        actualDuration: widget.session.duration,
      );

      await _sessionRepo.updateSession(updatedSession);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session completed!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatElapsedTime() {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: StudyTimerTemplate(
        goalTitle: widget.goal.title,
        subject: widget.goal.subject,
        elapsedSeconds: _elapsedSeconds,
        targetMinutes: widget.session.duration,
        timerState: _timerState,
        onBack: _handleBack,
        onStart: _startTimer,
        onPause: _pauseTimer,
        onResume: _resumeTimer,
        onStop: _stopTimer,
        onComplete: _completeSession,
      ),
    );
  }
}
