import 'package:equatable/equatable.dart';

/// Domain entity representing a timer session for a habit.
class TimerSession extends Equatable {
  const TimerSession({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.startedAt,
    required this.targetSeconds,
    required this.actualSeconds,
    required this.status,
    this.completedAt,
    this.pauseCount = 0,
    this.totalPausedSeconds = 0,
  });

  final String id;
  final String habitId;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int targetSeconds; // Target duration in seconds
  final int actualSeconds; // Actual duration completed
  final TimerSessionStatus status;
  final int pauseCount; // Number of times paused
  final int totalPausedSeconds; // Total time spent paused

  /// Check if target was met or exceeded
  bool get targetMet => actualSeconds >= targetSeconds;

  /// Get completion percentage
  double get completionPercentage {
    if (targetSeconds == 0) return 0.0;
    return (actualSeconds / targetSeconds * 100).clamp(0.0, 100.0);
  }

  /// Get duration as Duration object
  Duration get duration => Duration(seconds: actualSeconds);

  /// Get target as Duration object
  Duration get target => Duration(seconds: targetSeconds);

  TimerSession copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? targetSeconds,
    int? actualSeconds,
    TimerSessionStatus? status,
    int? pauseCount,
    int? totalPausedSeconds,
  }) {
    return TimerSession(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      status: status ?? this.status,
      pauseCount: pauseCount ?? this.pauseCount,
      totalPausedSeconds: totalPausedSeconds ?? this.totalPausedSeconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        startedAt,
        completedAt,
        targetSeconds,
        actualSeconds,
        status,
        pauseCount,
        totalPausedSeconds,
      ];
}

/// Timer session status enum.
enum TimerSessionStatus {
  completed, // Session completed successfully
  abandoned, // User stopped before target
  interrupted, // App was closed or crashed
}

/// Extension to convert string to TimerSessionStatus.
extension TimerSessionStatusExtension on String {
  TimerSessionStatus toTimerSessionStatus() {
    switch (this) {
      case 'completed':
        return TimerSessionStatus.completed;
      case 'abandoned':
        return TimerSessionStatus.abandoned;
      case 'interrupted':
        return TimerSessionStatus.interrupted;
      default:
        return TimerSessionStatus.completed;
    }
  }
}

/// Extension to convert enum to string.
extension TimerSessionStatusString on TimerSessionStatus {
  String get value {
    switch (this) {
      case TimerSessionStatus.completed:
        return 'completed';
      case TimerSessionStatus.abandoned:
        return 'abandoned';
      case TimerSessionStatus.interrupted:
        return 'interrupted';
    }
  }
}
