import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timer_session.dart' as domain;

/// Data model for TimerSession that extends the domain entity.
class TimerSessionModel extends domain.TimerSession {
  const TimerSessionModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.startedAt,
    required super.targetSeconds,
    required super.actualSeconds,
    required super.status,
    super.completedAt,
    super.pauseCount,
    super.totalPausedSeconds,
  });

  /// Create TimerSessionModel from domain entity.
  factory TimerSessionModel.fromEntity(domain.TimerSession session) {
    return TimerSessionModel(
      id: session.id,
      habitId: session.habitId,
      userId: session.userId,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      targetSeconds: session.targetSeconds,
      actualSeconds: session.actualSeconds,
      status: session.status,
      pauseCount: session.pauseCount,
      totalPausedSeconds: session.totalPausedSeconds,
    );
  }

  /// Create TimerSessionModel from Firestore document.
  factory TimerSessionModel.fromFirestore(Map<String, dynamic> json) {
    return TimerSessionModel(
      id: json['sessionId'] as String,
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      targetSeconds: json['targetSeconds'] as int,
      actualSeconds: json['actualSeconds'] as int,
      status: (json['status'] as String).toTimerSessionStatus(),
      pauseCount: json['pauseCount'] as int? ?? 0,
      totalPausedSeconds: json['totalPausedSeconds'] as int? ?? 0,
    );
  }

  /// Convert TimerSessionModel to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': id,
      'habitId': habitId,
      'userId': userId,
      'startedAt': Timestamp.fromDate(startedAt),
      if (completedAt != null)
        'completedAt': Timestamp.fromDate(completedAt!),
      'targetSeconds': targetSeconds,
      'actualSeconds': actualSeconds,
      'status': status.value,
      'pauseCount': pauseCount,
      'totalPausedSeconds': totalPausedSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to domain entity.
  domain.TimerSession toEntity() {
    return domain.TimerSession(
      id: id,
      habitId: habitId,
      userId: userId,
      startedAt: startedAt,
      completedAt: completedAt,
      targetSeconds: targetSeconds,
      actualSeconds: actualSeconds,
      status: status,
      pauseCount: pauseCount,
      totalPausedSeconds: totalPausedSeconds,
    );
  }

  @override
  TimerSessionModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? targetSeconds,
    int? actualSeconds,
    domain.TimerSessionStatus? status,
    int? pauseCount,
    int? totalPausedSeconds,
  }) {
    return TimerSessionModel(
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
}
