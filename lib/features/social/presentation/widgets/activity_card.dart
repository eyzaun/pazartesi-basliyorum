import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/habit_activity.dart';

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
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Photo if available
              if (activity.photoUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: activity.photoUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
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

              // Quality if available
              if (activity.quality != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getQualityText(activity.quality!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
