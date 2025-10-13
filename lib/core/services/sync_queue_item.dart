import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 0)
class SyncQueueItem extends HiveObject {

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.isSyncing = false,
    this.error,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      operation: map['operation'] as String,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      data: map['data'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
      isSyncing: map['isSyncing'] as bool? ?? false,
      error: map['error'] as String?,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String operation; // 'create', 'update', 'delete'

  @HiveField(2)
  final String entityType; // 'habit', 'log', 'user', 'achievement'

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final String data; // JSON encoded

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int retryCount;

  @HiveField(7)
  final bool isSyncing;

  @HiveField(8)
  final String? error;

  SyncQueueItem copyWith({
    String? id,
    String? operation,
    String? entityType,
    String? entityId,
    String? data,
    DateTime? createdAt,
    int? retryCount,
    bool? isSyncing,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'isSyncing': isSyncing,
      'error': error,
    };
  }
}

enum SyncState {
  idle,
  syncing,
  success,
  failed,
  conflict,
}
