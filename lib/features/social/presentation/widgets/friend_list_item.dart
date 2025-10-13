import 'package:flutter/material.dart';

import '../../domain/entities/friend.dart';

/// List item widget for displaying a friend.
class FriendListItem extends StatelessWidget {
  const FriendListItem({
    required this.friend,
    required this.currentUserId,
    super.key,
    this.onTap,
    this.trailing,
  });

  final Friend friend;
  final String currentUserId;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine which user info to show (the friend, not current user)
    final displayName = friend.userId == currentUserId
        ? friend.friendDisplayName
        : friend.friendDisplayName;
    final username = friend.userId == currentUserId
        ? friend.friendUsername
        : friend.friendUsername;
    final photoUrl = friend.userId == currentUserId
        ? friend.friendPhotoUrl
        : friend.friendPhotoUrl;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Text(displayName[0].toUpperCase())
            : null,
      ),
      title: Text(
        displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text('@$username'),
      trailing: trailing,
    );
  }
}
