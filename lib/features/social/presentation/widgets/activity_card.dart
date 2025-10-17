import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/habit_activity.dart';
import '../../utils/habit_summary.dart';

/// Card widget for displaying a habit activity in the feed.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.activity,
    required this.currentUserId,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final HabitActivity activity;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwnActivity = activity.userId == currentUserId;
    final metaChips = _buildMetaChips(activity, theme);
    final footerItems = _buildFooterInfo(activity, theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: User info and timestamp
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(activity.username[0].toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.username,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(activity.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Only show delete button for own activities
                  if (isOwnActivity && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Habit info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha((0.25 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconFromString(activity.habitIcon),
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${activity.habitName} alışkanlığını tamamladı! 🎉',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (activity.habitDescription != null &&
                        activity.habitDescription!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        activity.habitDescription!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ],
                    if (metaChips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: metaChips,
                      ),
                    ],
                  ],
                ),
              ),

              // Photo if available
              if (activity.photoUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CachedNetworkImage(
                      imageUrl: activity.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ],

              // Note if available
              if (activity.note != null && activity.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  activity.note!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],

              if (footerItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: footerItems,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetaChips(HabitActivity activity, ThemeData theme) {
    final chips = <Widget>[];

    if (activity.habitCategory != null && activity.habitCategory!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.category_outlined,
        formatCategoryLabel(activity.habitCategory!),
      ));
    }
    if (activity.habitFrequencyLabel != null &&
        activity.habitFrequencyLabel!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.calendar_today_outlined,
        activity.habitFrequencyLabel!,
      ));
    }
    if (activity.habitGoalLabel != null &&
        activity.habitGoalLabel!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.flag_outlined,
        activity.habitGoalLabel!,
      ));
    }

    return chips;
  }

  List<Widget> _buildFooterInfo(HabitActivity activity, ThemeData theme) {
    final items = <Widget>[];

    if (activity.quality != null && activity.quality!.isNotEmpty) {
      items.add(_buildInfoRow(
        theme,
        Icons.star,
        _getQualityText(activity.quality!),
        iconColor: Colors.amber[700],
      ));
    }

    if (activity.timerDuration != null && activity.timerDuration! > 0) {
      items.add(_buildInfoRow(
        theme,
        Icons.timer_outlined,
        _formatTimerDuration(activity.timerDuration!),
      ));
    }

    final completedLabel =
        DateFormat('d MMM - HH:mm', 'tr').format(activity.completedAt);
    items.add(_buildInfoRow(
      theme,
      Icons.access_time,
      completedLabel,
    ));

    return items;
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.surfaceContainerHighest
          .withAlpha((0.7 * 255).round()),
      avatar: Icon(
        icon,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label, {
    Color? iconColor,
  }) {
    final resolvedColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatTimerDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sn';
    }
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (remaining == 0) {
      return '$minutes dk';
    }
    return '$minutes dk ${remaining.toString().padLeft(2, '0')} sn';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      final formatter = DateFormat('d MMM', 'tr');
      return formatter.format(dateTime);
    }
  }

  IconData _getIconFromString(String iconString) {
    // habitIcon is stored as "iconName" like "fitness_center", "book", etc.
    // Map common icon names to IconData
    final iconMap = {
      'fitness_center': Icons.fitness_center,
      'book': Icons.book,
      'water_drop': Icons.water_drop,
      'bedtime': Icons.bedtime,
      'restaurant': Icons.restaurant,
      'directions_run': Icons.directions_run,
      'self_improvement': Icons.self_improvement,
      'brush': Icons.brush,
      'school': Icons.school,
      'work': Icons.work,
      'music_note': Icons.music_note,
      'palette': Icons.palette,
      'camera_alt': Icons.camera_alt,
      'code': Icons.code,
      'favorite': Icons.favorite,
      'spa': Icons.spa,
      'smoking_rooms': Icons.smoking_rooms,
      'local_cafe': Icons.local_cafe,
      'pets': Icons.pets,
      'park': Icons.park,
    };

    return iconMap[iconString] ?? Icons.check_circle;
  }

  String _getQualityText(String quality) {
    switch (quality) {
      case 'excellent':
        return 'Mükemmel';
      case 'good':
        return 'İyi';
      case 'fair':
        return 'Normal';
      case 'poor':
        return 'Zayıf';
      default:
        return quality;
    }
  }
}
