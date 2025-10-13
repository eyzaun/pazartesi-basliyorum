import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'connectivity_service.dart';
import 'sync_queue_item.dart';

class SyncService {

  SyncService(
    this._queueBox,
    this._firestore,
    this._auth,
    this._connectivity,
  ) {
    _initializeSync();
  }
  final Box<SyncQueueItem> _queueBox;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ConnectivityService _connectivity;

  // Sync state stream
  final _syncStateController = BehaviorSubject<SyncState>.seeded(SyncState.idle);
  Stream<SyncState> get syncState => _syncStateController.stream;

  // Pending operations count
  final _pendingCountController = BehaviorSubject<int>.seeded(0);
  Stream<int> get pendingCount => _pendingCountController.stream;

  // Last sync time
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  bool _isSyncing = false;

  void _initializeSync() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    });

    // Update pending count initially
    _updatePendingCount();

    // Listen to queue changes
    _queueBox.watch().listen((_) {
      _updatePendingCount();
    });
  }

  void _updatePendingCount() {
    final count = _queueBox.values
        .where((item) => !item.isSyncing && item.retryCount < 3)
        .length;
    _pendingCountController.add(count);
  }

  // Add operation to queue
  Future<void> queueOperation({
    required String operation,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final queueItem = SyncQueueItem(
      id: const Uuid().v4(),
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      data: jsonEncode(data),
      createdAt: DateTime.now(),
    );

    await _queueBox.put(queueItem.id, queueItem);

    // Try to sync immediately if online
    if (await _connectivity.checkConnectivity() && !_isSyncing) {
      syncPendingOperations();
    }
  }

  // Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (!await _connectivity.checkConnectivity()) {
      return;
    }

    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _syncStateController.add(SyncState.syncing);

    try {
      final pendingOps = _queueBox.values
          .where((item) => !item.isSyncing && item.retryCount < 3)
          .toList();

      if (pendingOps.isEmpty) {
        _syncStateController.add(SyncState.idle);
        _isSyncing = false;
        return;
      }

      // Sort by createdAt to maintain order
      pendingOps.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final op in pendingOps) {
        await _syncOperation(op);
      }

      _lastSyncTime = DateTime.now();
      _syncStateController.add(SyncState.success);

      // Auto-dismiss success state after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_syncStateController.value == SyncState.success) {
          _syncStateController.add(SyncState.idle);
        }
      });
    } catch (e) {
      _syncStateController.add(SyncState.failed);
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncOperation(SyncQueueItem op) async {
    // Mark as syncing
    final updatedOp = op.copyWith(isSyncing: true);
    await _queueBox.put(op.id, updatedOp);

    try {
      final data = jsonDecode(op.data) as Map<String, dynamic>;

      switch (op.operation) {
        case 'create':
          await _syncCreate(op.entityType, op.entityId, data);
          break;
        case 'update':
          await _syncUpdate(op.entityType, op.entityId, data);
          break;
        case 'delete':
          await _syncDelete(op.entityType, op.entityId);
          break;
      }

      // Success - remove from queue
      await _queueBox.delete(op.id);
    } catch (e) {
      // Failure - increment retry count
      final failedOp = op.copyWith(
        isSyncing: false,
        retryCount: op.retryCount + 1,
        error: e.toString(),
      );
      await _queueBox.put(op.id, failedOp);

      // Max 3 retries
      if (op.retryCount >= 2) {
        _syncStateController.add(SyncState.failed);
        print('Max retries reached for operation ${op.id}: ${e.toString()}');
      }

      rethrow;
    }
  }

  Future<void> _syncCreate(
    String type,
    String id,
    Map<String, dynamic> data,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    switch (type) {
      case 'habit':
        await _firestore.collection('habits').doc(id).set(data);
        break;
      case 'log':
        await _firestore.collection('habit_logs').doc(id).set(data);
        break;
      case 'user':
        await _firestore.collection('users').doc(id).set(data);
        break;
      case 'achievement':
        await _firestore.collection('achievements').doc(id).set(data);
        break;
      case 'streak_recovery':
        await _firestore.collection('streak_recoveries').doc(id).set(data);
        break;
    }
  }

  Future<void> _syncUpdate(
    String type,
    String id,
    Map<String, dynamic> data,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    switch (type) {
      case 'habit':
        await _firestore.collection('habits').doc(id).update(data);
        break;
      case 'log':
        await _firestore.collection('habit_logs').doc(id).update(data);
        break;
      case 'user':
        await _firestore.collection('users').doc(id).update(data);
        break;
      case 'achievement':
        await _firestore.collection('achievements').doc(id).update(data);
        break;
      case 'streak_recovery':
        await _firestore.collection('streak_recoveries').doc(id).update(data);
        break;
    }
  }

  Future<void> _syncDelete(String type, String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    switch (type) {
      case 'habit':
        await _firestore.collection('habits').doc(id).delete();
        break;
      case 'log':
        await _firestore.collection('habit_logs').doc(id).delete();
        break;
      case 'streak_recovery':
        await _firestore.collection('streak_recoveries').doc(id).delete();
        break;
    }
  }

  // Get pending operations for debugging
  List<SyncQueueItem> getPendingOperations() {
    return _queueBox.values
        .where((item) => !item.isSyncing && item.retryCount < 3)
        .toList();
  }

  // Get failed operations
  List<SyncQueueItem> getFailedOperations() {
    return _queueBox.values
        .where((item) => item.retryCount >= 3)
        .toList();
  }

  // Retry failed operations
  Future<void> retryFailedOperations() async {
    final failedOps = getFailedOperations();
    for (final op in failedOps) {
      final resetOp = op.copyWith(
        retryCount: 0,
        isSyncing: false,
      );
      await _queueBox.put(op.id, resetOp);
    }

    await syncPendingOperations();
  }

  // Clear all failed operations
  Future<void> clearFailedOperations() async {
    final failedOps = getFailedOperations();
    for (final op in failedOps) {
      await _queueBox.delete(op.id);
    }
    _updatePendingCount();
  }

  void dispose() {
    _syncStateController.close();
    _pendingCountController.close();
  }
}

// Providers
final syncQueueBoxProvider = FutureProvider<Box<SyncQueueItem>>((ref) async {
  if (!Hive.isBoxOpen('sync_queue')) {
    return Hive.openBox<SyncQueueItem>('sync_queue');
  }
  return Hive.box<SyncQueueItem>('sync_queue');
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final queueBox = ref.watch(syncQueueBoxProvider).value;
  if (queueBox == null) {
    throw Exception('Sync queue box not initialized');
  }

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final connectivity = ref.watch(connectivityServiceProvider);

  return SyncService(queueBox, firestore, auth, connectivity);
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncState;
});

final pendingCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.pendingCount;
});
