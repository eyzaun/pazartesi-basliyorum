import 'package:flutter/material.dart';

import '../screens/statistics_screen.dart';

/// Card showing top 3 habits leaderboard.
class TopHabitsCard extends StatelessWidget {
  const TopHabitsCard({
    required this.topHabits,
    super.key,
  });

  final List<TopHabitData> topHabits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'En İyi 3 Alışkanlık',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topHabits.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Henüz veri yok'),
                ),
              )
            else
              ...topHabits.asMap().entries.map((entry) {
                final index = entry.key;
                final habitData = entry.value;
                return _buildHabitRow(
                  context,
                  rank: index + 1,
                  habitData: habitData,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitRow(
    BuildContext context, {
    required int rank,
    required TopHabitData habitData,
  }) {
    final theme = Theme.of(context);
    final medal = _getMedalEmoji(rank);
    final habit = habitData.habit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank medal
          Text(
            medal,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),

          // Habit icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColorFromHex(habit.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              habit.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Habit name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${habitData.completionCount} tamamlama • ${(habitData.completionRate * 100).round()}% oran',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: habitData.completionRate,
              backgroundColor: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }
}
