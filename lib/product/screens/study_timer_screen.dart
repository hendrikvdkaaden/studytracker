import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../providers/app_providers.dart';
import '../../services/notification_service.dart';
import '../../services/study_session_repository.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/study_timer/timer_controls.dart';
import '../templates/study_timer_template.dart';

class StudyTimerScreen extends ConsumerStatefulWidget {
  final StudySession session;
  final Goal goal;

  const StudyTimerScreen({
    super.key,
    required this.session,
    required this.goal,
  });

  @override
  ConsumerState<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends ConsumerState<StudyTimerScreen>
    with WidgetsBindingObserver {
  StudySessionRepository get _sessionRepo => ref.read(studySessionRepositoryProvider);
  late final ConfettiController _confettiController;
  Timer? _timer;
  int _elapsedSeconds = 0;
  TimerState _timerState = TimerState.initial;
  bool _hasTriggeredCompletion = false;

  int get _targetSeconds => widget.session.duration * 60;
  int get _remainingSeconds => (_targetSeconds - _elapsedSeconds).clamp(0, _targetSeconds);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // A completed session starts fresh: resuming it would otherwise open on a
    // timer that already reads 00:00 with no way to run it but "Restart".
    if (!widget.session.isCompleted && widget.session.elapsedSeconds != null) {
      _elapsedSeconds = widget.session.elapsedSeconds!;
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        _timerState == TimerState.running) {
      NotificationService.showResumeSessionNotification(widget.goal.title);
    } else if (state == AppLifecycleState.resumed) {
      NotificationService.cancelResumeSessionNotification();
    }
  }

  void _startTimer() {
    setState(() {
      if (_timerState == TimerState.completed) {
        _elapsedSeconds = 0;
        _hasTriggeredCompletion = false;
      }
      _timerState = TimerState.running;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds % 30 == 0) {
          _persistElapsedSeconds();
        }
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _timerState = TimerState.completed;
        }
      });
      if (_remainingSeconds <= 0) {
        _persistElapsedSeconds();
        if (!_hasTriggeredCompletion) {
          _hasTriggeredCompletion = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confettiController.play();
            _triggerHapticPattern();
          });
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timerState = TimerState.paused;
    });
    _persistElapsedSeconds();
  }

  void _resumeTimer() {
    _startTimer();
  }

  Future<void> _persistElapsedSeconds() async {
    final updated = widget.session.copyWith(elapsedSeconds: _elapsedSeconds);
    await _sessionRepo.updateSession(updated);
  }

  Future<void> _stopTimer() async {
    final l10n = context.l10n;
    final elapsedTime = _formatElapsedTime();
    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.timerDialogCompleteTitle,
      message: l10n.timerDialogCompleteBody(elapsedTime),
      confirmLabel: l10n.timerDialogCompleteConfirm,
      cancelLabel: l10n.timerDialogCompleteCancel,
      icon: Icons.save_outlined,
    );

    if (confirm) {
      _timer?.cancel();
      final actualMinutes = _elapsedSeconds ~/ 60;
      final updatedSession = widget.session.copyWith(
        // Time studied is kept in actualDuration; elapsedSeconds only exists to
        // resume a running timer, so a finished session resets it.
        actualDuration: actualMinutes,
        elapsedSeconds: 0,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      await _sessionRepo.updateSession(updatedSession);

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  Future<void> _handleBack() async {
    if (_timerState != TimerState.initial) {
      final l10n = context.l10n;
      final confirm = await showAppConfirmDialog(
        context: context,
        title: l10n.timerDialogLeaveTitle,
        message: l10n.timerDialogLeaveBody,
        confirmLabel: l10n.timerDialogLeaveConfirm,
        cancelLabel: l10n.timerDialogLeaveCancel,
        icon: Icons.exit_to_app,
      );

      if (confirm) {
        _timer?.cancel();
        if (_timerState == TimerState.completed) {
          final updatedSession = widget.session.copyWith(
            actualDuration: widget.session.duration,
            elapsedSeconds: 0,
            isCompleted: true,
            completedAt: DateTime.now(),
          );
          await _sessionRepo.updateSession(updatedSession);
        } else {
          await _persistElapsedSeconds();
        }
        if (mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeSession() async {
    final l10n = context.l10n;
    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.timerDialogMarkCompleteTitle,
      message: l10n.timerDialogMarkCompleteBody,
      confirmLabel: l10n.timerDialogMarkCompleteConfirm,
      cancelLabel: l10n.timerDialogCompleteCancel,
      icon: Icons.check_circle_outline,
    );

    if (confirm) {
      _timer?.cancel();

      final updatedSession = widget.session.copyWith(
        // The full session duration is logged via actualDuration; elapsed is
        // reset so reopening the session starts a clean timer rather than one
        // already sitting at 00:00.
        actualDuration: widget.session.duration,
        elapsedSeconds: 0,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      await _sessionRepo.updateSession(updatedSession);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void _triggerHapticPattern() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.heavyImpact();
    });
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
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
        confettiController: _confettiController,
      ),
    );
  }
}
