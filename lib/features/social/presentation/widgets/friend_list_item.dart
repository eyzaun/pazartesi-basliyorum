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

    // The repository constructs Friend objects so that `friend*` fields
    // represent the other user's public info. Prefer those fields and
    // fall back to safe defaults.
    final displayName = friend.friendDisplayName.isNotEmpty
        ? friend.friendDisplayName
        : 'Unknown';
    final username =
        friend.friendUsername.isNotEmpty ? friend.friendUsername : '';
    final photoUrl = friend.friendPhotoUrl;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Text(
                (displayName.isNotEmpty ? displayName[0] : '?').toUpperCase(),
              )
            : null,
      ),
      title: Text(
        displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: username.isNotEmpty ? Text('@$username') : null,
      trailing: trailing,
    );
  }
}
