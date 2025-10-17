import 'package:flutter/material.dart';

import '../../domain/entities/shared_habit.dart';
import '../../utils/habit_summary.dart';

/// Card widget for displaying a shared habit.
class SharedHabitCard extends StatelessWidget {
  const SharedHabitCard({
    required this.sharedHabit,
    required this.currentUserId,
    super.key,
    this.onTap,
    this.onUnshare,
  });

  final SharedHabit sharedHabit;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onUnshare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = sharedHabit.ownerId == currentUserId;
    final metaChips = _buildMetaChips(sharedHabit, theme);
    final sharingChips = _buildSharingChips(sharedHabit, theme, isOwner);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHabitAvatar(sharedHabit, theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sharedHabit.habitName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (sharedHabit.habitDescription != null &&
                            sharedHabit.habitDescription!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            sharedHabit.habitDescription!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onUnshare != null)
                    IconButton(
                      onPressed: onUnshare,
                      icon: const Icon(Icons.close),
                      tooltip: 'Paylaşımı Kaldır',
                    ),
                ],
              ),
              if (metaChips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: metaChips,
                ),
              ],
              if (sharingChips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: sharingChips,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetaChips(SharedHabit habit, ThemeData theme) {
    final chips = <Widget>[];

    if (habit.habitCategory != null && habit.habitCategory!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.category_outlined,
        formatCategoryLabel(habit.habitCategory!),
      ));
    }
    if (habit.habitFrequencyLabel != null &&
        habit.habitFrequencyLabel!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.calendar_today_outlined,
        habit.habitFrequencyLabel!,
      ));
    }
    if (habit.habitGoalLabel != null && habit.habitGoalLabel!.isNotEmpty) {
      chips.add(_buildInfoChip(
        theme,
        Icons.flag_outlined,
        habit.habitGoalLabel!,
      ));
    }

    return chips;
  }

  List<Widget> _buildSharingChips(
    SharedHabit habit,
    ThemeData theme,
    bool isOwner,
  ) {
    final chips = <Widget>[
      Chip(
        avatar: Icon(
          isOwner ? Icons.person : Icons.person_outline,
          size: 16,
        ),
        label: Text(
          isOwner
              ? 'Paylaştığın: @${habit.sharedWithUsername}'
              : 'Paylaşan: @${habit.ownerUsername}',
          style: theme.textTheme.bodySmall,
        ),
        visualDensity: VisualDensity.compact,
      ),
    ];

    if (habit.canEdit == true) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.edit, size: 16),
          label: Text(
            'Düzenlenebilir',
            style: theme.textTheme.bodySmall,
          ),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return chips;
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

  Widget _buildHabitAvatar(SharedHabit habit, ThemeData theme) {
    final baseColor = habit.habitColor != null
        ? Color(habit.habitColor!)
        : theme.colorScheme.primary;
    final iconData = _iconFromString(habit.habitIcon);

    if (iconData != null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: baseColor.withAlpha((0.2 * 255).round()),
        child: Icon(
          iconData,
          color: baseColor,
        ),
      );
    }

    if (habit.habitIcon != null && habit.habitIcon!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: baseColor.withAlpha((0.2 * 255).round()),
        child: Text(
          habit.habitIcon!,
          style: const TextStyle(fontSize: 22),
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: baseColor.withAlpha((0.2 * 255).round()),
      child: Icon(
        Icons.fitness_center,
        color: baseColor,
      ),
    );
  }

  IconData? _iconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) return null;
    const iconMap = {
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

    return iconMap[iconString];
  }

}
