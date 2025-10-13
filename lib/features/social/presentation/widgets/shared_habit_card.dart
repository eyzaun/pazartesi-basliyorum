import 'package:flutter/material.dart';

import '../../domain/entities/shared_habit.dart';

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
                children: [
                  if (sharedHabit.habitIcon != null)
                    Text(
                      sharedHabit.habitIcon!,
                      style: const TextStyle(fontSize: 32),
                    )
                  else
                    Icon(
                      Icons.fitness_center,
                      size: 32,
                      color: sharedHabit.habitColor != null
                          ? Color(sharedHabit.habitColor!)
                          : theme.colorScheme.primary,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sharedHabit.habitName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (sharedHabit.habitDescription != null)
                          Text(
                            sharedHabit.habitDescription!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      isOwner ? Icons.person : Icons.person_outline,
                      size: 16,
                    ),
                    label: Text(
                      isOwner
                          ? 'Paylaştığın: @${sharedHabit.sharedWithUsername}'
                          : 'Paylaşan: @${sharedHabit.ownerUsername}',
                      style: theme.textTheme.bodySmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (sharedHabit.canEdit == true)
                    Chip(
                      avatar: const Icon(Icons.edit, size: 16),
                      label: Text(
                        'Düzenlenebilir',
                        style: theme.textTheme.bodySmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
