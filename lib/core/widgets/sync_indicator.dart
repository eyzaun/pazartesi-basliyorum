import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_queue_item.dart';
import '../services/sync_service.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncStateProvider);
    final pendingCountAsync = ref.watch(pendingCountProvider);

    return syncStateAsync.when(
      data: (syncState) {
        return pendingCountAsync.when(
          data: (count) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildIndicator(context, ref, syncState, count),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    WidgetRef ref,
    SyncState state,
    int count,
  ) {
    switch (state) {
      case SyncState.idle:
        if (count > 0) {
          return _buildPendingIndicator(context, count);
        }
        return const SizedBox.shrink();

      case SyncState.syncing:
        return _buildSyncingIndicator(context);

      case SyncState.success:
        return _buildSuccessIndicator(context);

      case SyncState.failed:
        return _buildFailedIndicator(context, ref);

      case SyncState.conflict:
        return _buildConflictIndicator(context);
    }
  }

  Widget _buildPendingIndicator(BuildContext context, int count) {
    return Container(
      key: const ValueKey('pending'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '$count değişiklik bekliyor',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingIndicator(BuildContext context) {
    return Container(
      key: const ValueKey('syncing'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Senkronize ediliyor...',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIndicator(BuildContext context) {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            'Senkronize edildi',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedIndicator(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      key: const ValueKey('failed'),
      onTap: () => ref.read(syncServiceProvider).syncPendingOperations(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text(
              'Senkronizasyon hatası',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.refresh, size: 14, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictIndicator(BuildContext context) {
    return Container(
      key: const ValueKey('conflict'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.purple, size: 16),
          SizedBox(width: 4),
          Text(
            'Çakışma',
            style: TextStyle(
              fontSize: 11,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Small version for habit cards
class HabitCardSyncBadge extends ConsumerWidget {
  final String habitId;

  const HabitCardSyncBadge({
    required this.habitId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingCountProvider);

    return pendingCountAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        // Check if this habit has pending operations
        final syncService = ref.watch(syncServiceProvider);
        final hasPending = syncService.getPendingOperations().any(
              (op) => op.entityId == habitId && op.entityType == 'habit',
            );

        if (!hasPending) return const SizedBox.shrink();

        return Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload,
              size: 12,
              color: Colors.white,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
