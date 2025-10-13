import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

/// Widget to display a single achievement badge.
class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    required this.achievement,
    super.key,
    this.size = BadgeSize.medium,
    this.showDate = false,
  });

  final Achievement achievement;
  final BadgeSize size;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeType = achievement.badgeType;

    final dimension = size == BadgeSize.small
        ? 60.0
        : size == BadgeSize.medium
            ? 80.0
            : 100.0;
    final iconSize = size == BadgeSize.small
        ? 30.0
        : size == BadgeSize.medium
            ? 40.0
            : 50.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD700), // Gold
                Color(0xFFFFA500), // Orange
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              badgeType.icon,
              style: TextStyle(fontSize: iconSize),
            ),
          ),
        ),
        if (size != BadgeSize.small) ...[
          const SizedBox(height: 8),
          Text(
            badgeType.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            badgeType.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (showDate) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(achievement.unlockedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Bugün';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

enum BadgeSize {
  small,
  medium,
  large,
}
