import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import 'detailed_checkin_sheet.dart';
import 'skip_reason_sheet.dart';

/// Card widget to display a habit with check-in options and swipe actions.
class HabitCard extends StatelessWidget {
  const HabitCard({
    required this.habit,
    super.key,
    this.log,
    this.onComplete,
    this.onSkip,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.showStreakWarning = false,
    this.onRecoverStreak,
  });

  final Habit habit;
  final HabitLog? log;
  final void Function(Map<String, dynamic>)? onComplete;
  final void Function(Map<String, dynamic>)? onSkip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool showStreakWarning;
  final VoidCallback? onRecoverStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = log?.completed ?? false;
    final isSkipped = log?.skipped ?? false;

    // Determine card background color based on status
    Color? cardColor;
    if (isCompleted) {
      cardColor = Colors.green[50];
    } else if (isSkipped) {
      cardColor = Colors.orange[50];
    }

    return Slidable(
      key: ValueKey(habit.id),

      // Enable quick complete by dismissing (swipe right)
      // Only allow if not completed or skipped
      enabled: !isCompleted && !isSkipped,

      // Left swipe actions (complete with quality)
      startActionPane: !isCompleted && !isSkipped
          ? ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    HapticFeedback.mediumImpact();
                    _quickComplete(context);
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle,
                  label: 'Tamamla',
                  autoClose: true,
                ),
              ],
            )
          : null,

      // Right swipe actions (share, edit, delete)
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          if (onShare != null)
            SlidableAction(
              onPressed: (_) => onShare?.call(),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Paylaş',
            ),
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Düzenle',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
          ),
        ],
      ),

      child: Card(
        elevation: isCompleted ? 1 : 2,
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and status
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getColorFromHex(habit.color)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        habit.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status indicator
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tamamlandı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isSkipped)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.skip_next,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Atlandı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Description (if available)
                if (habit.description != null &&
                    habit.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    habit.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Streak warning banner
                if (showStreakWarning && !isCompleted && !isSkipped) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.orange[300]!, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seri Kırıldı',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Serini kurtarmak için 24 saat içinde işlem yap',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onRecoverStreak != null)
                          TextButton(
                            onPressed: onRecoverStreak,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange[900],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              'Kurtar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Action buttons (only show if not completed or skipped)
                if (!isCompleted && !isSkipped) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Complete button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showQualitySelector(context),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Tamamla'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Skip button
                      OutlinedButton.icon(
                        onPressed: () => _showSkipReasonSheet(context),
                        icon: const Icon(Icons.skip_next, size: 18),
                        label: const Text('Atla'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Show note if completed with note
                if (isCompleted &&
                    log?.note != null &&
                    log!.note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            log!.note!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Show skip reason if skipped
                if (isSkipped && log?.skipReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Neden: ${log!.skipReason}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Quick complete without quality selection (swipe right gesture)
  void _quickComplete(BuildContext context) async {
    // Complete with default good quality and no note
    final data = {
      'quality': LogQuality.good,
      'note': null,
      'photo': null,
    };

    // Call completion callback
    onComplete?.call(data);

    // Wait a bit to let parent refresh after dismiss animation
    await Future.delayed(const Duration(milliseconds: 50));

    // Show brief success feedback (if still mounted)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Hızlı tamamlandı! ⚡'),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show detailed check-in bottom sheet
  Future<void> _showQualitySelector(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailedCheckInSheet(habit: habit),
    );

    if (result != null) {
      onComplete?.call(result);
    }
  }

  /// Show skip reason bottom sheet
  Future<void> _showSkipReasonSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkipReasonSheet(habit: habit),
    );

    if (result != null) {
      onSkip?.call(result);
    }
  }

  /// Convert hex color string to Color.
  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }
}
