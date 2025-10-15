import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/timer_session.dart';
import 'timer_session_providers.dart';

/// State for habit timer
class HabitTimerState {
  const HabitTimerState({
    required this.habitId,
    required this.status,
    required this.elapsed,
    this.target,
    this.sessionId,
  });

  final String habitId;
  final TimerStatus status;
  final Duration elapsed;
  final Duration? target;
  final String? sessionId;

  HabitTimerState copyWith({
    String? habitId,
    TimerStatus? status,
    Duration? elapsed,
    Duration? target,
    String? sessionId,
  }) {
    return HabitTimerState(
      habitId: habitId ?? this.habitId,
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      target: target ?? this.target,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (target == null || target!.inSeconds == 0) return 0.0;
    return (elapsed.inSeconds / target!.inSeconds).clamp(0.0, 1.0);
  }
}

/// Timer status enum
enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}

/// Habit timer notifier
class HabitTimerNotifier extends StateNotifier<HabitTimerState> {
  HabitTimerNotifier(
    this._ref,
    String habitId,
    Duration? targetDuration,
  ) : super(HabitTimerState(
          habitId: habitId,
          status: TimerStatus.idle,
          elapsed: Duration.zero,
          target: targetDuration,
        ));

  final Ref _ref;
  Timer? _timer;
  DateTime? _startTime;
  Duration _pausedDuration = Duration.zero;
  int _pauseCount = 0;

  /// Start the timer
  void start() {
    if (state.status == TimerStatus.running) return;

    _startTime = DateTime.now();
    
    // If resuming from pause, keep existing elapsed time
    if (state.status != TimerStatus.paused) {
      _pausedDuration = Duration.zero;
      _pauseCount = 0;
      
      // Create new session
      final sessionId = const Uuid().v4();
      state = state.copyWith(
        status: TimerStatus.running,
        sessionId: sessionId,
      );
    } else {
      _pauseCount++;
      state = state.copyWith(status: TimerStatus.running);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final running = now.difference(_startTime!);
      final total = _pausedDuration + running;

      state = state.copyWith(
        elapsed: total,
      );

      // Check if target reached
      if (state.target != null && total >= state.target!) {
        _onTargetReached();
      }
    });

    // Keep screen on
    WakelockPlus.enable();
  }

  /// Pause the timer
  void pause() {
    if (state.status != TimerStatus.running) return;

    _timer?.cancel();
    _pausedDuration = state.elapsed;

    state = state.copyWith(status: TimerStatus.paused);

    // Allow screen to sleep
    WakelockPlus.disable();
  }

  /// Resume the timer
  void resume() {
    if (state.status != TimerStatus.paused) return;
    start();
  }

  /// Stop the timer and save session
  Future<void> stop() async {
    _timer?.cancel();
    WakelockPlus.disable();

    final finalDuration = state.elapsed;
    final sessionId = state.sessionId ?? const Uuid().v4();

    // Determine session status
    final sessionStatus = state.target != null && 
            finalDuration >= state.target!
        ? TimerSessionStatus.completed
        : TimerSessionStatus.abandoned;

    // Create timer session
    final session = TimerSession(
      id: sessionId,
      habitId: state.habitId,
      userId: 'current_user', // TODO: Get from auth
      startedAt: _startTime ?? DateTime.now(),
      completedAt: DateTime.now(),
      targetSeconds: state.target?.inSeconds ?? 0,
      actualSeconds: finalDuration.inSeconds,
      status: sessionStatus,
      pauseCount: _pauseCount,
      totalPausedSeconds: 0, // TODO: Calculate actual paused time
    );

    // Save to repository
    final repository = _ref.read(timerSessionRepositoryProvider);
    await repository.createSession(session);

    state = state.copyWith(
      status: TimerStatus.completed,
      elapsed: finalDuration,
    );
  }

  /// Add time to timer (for quick adjustments)
  void addTime(int seconds) {
    if (state.status == TimerStatus.idle) return;

    final newElapsed = state.elapsed + Duration(seconds: seconds);
    if (newElapsed.isNegative) return;

    if (state.status == TimerStatus.running) {
      // Adjust start time to compensate
      _startTime = _startTime!.subtract(Duration(seconds: seconds));
    } else if (state.status == TimerStatus.paused) {
      _pausedDuration = newElapsed;
      state = state.copyWith(elapsed: newElapsed);
    }
  }

  /// Handle target reached
  void _onTargetReached() {
    // Play sound and vibrate
    HapticFeedback.heavyImpact();
    
    // Don't auto-stop, let user manually stop
    // This allows them to go beyond target if they want
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}

/// Provider for habit timer
final habitTimerProvider =
    StateNotifierProvider.family<HabitTimerNotifier, HabitTimerState, String>(
  (ref, habitId) {
    // TODO: Get habit to extract target duration
    return HabitTimerNotifier(ref, habitId, const Duration(minutes: 20));
  },
);

/// Provider for habit timer with habit entity
final habitTimerWithHabitProvider = StateNotifierProvider.family<
    HabitTimerNotifier,
    HabitTimerState,
    Habit>(
  (ref, habit) {
    final targetDuration = habit.targetDurationMinutes != null
        ? Duration(minutes: habit.targetDurationMinutes!)
        : null;
    return HabitTimerNotifier(ref, habit.id, targetDuration);
  },
);
