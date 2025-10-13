import 'package:flutter/material.dart';

import '../../domain/entities/friend.dart';

/// Card widget for displaying a friend request.
class FriendRequestCard extends StatelessWidget {
  const FriendRequestCard({
    required this.friend,
    required this.onAccept,
    required this.onReject,
    super.key,
    this.isLoading = false,
  });

  final Friend friend;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: friend.friendPhotoUrl != null
                  ? NetworkImage(friend.friendPhotoUrl!)
                  : null,
              child: friend.friendPhotoUrl == null
                  ? Text(
                      friend.friendDisplayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.friendDisplayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${friend.friendUsername}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                    tooltip: 'Kabul Et',
                  ),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    tooltip: 'Reddet',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
