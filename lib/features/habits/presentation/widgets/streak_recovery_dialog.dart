import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

/// Dialog shown when a habit's streak breaks, offering recovery option.
///
/// Recovery Rules:
/// - Available only within 24 hours of missed day
/// - Can be used once per week per habit
/// - Shows remaining time and usage status
class StreakRecoveryDialog extends StatelessWidget {
  const StreakRecoveryDialog({
    required this.habit,
    required this.missedDate,
    required this.currentStreak,
    required this.canRecover,
    required this.reasonText,
    required this.onRecover,
    required this.onSkip,
    super.key,
  });

  final Habit habit;
  final DateTime missedDate;
  final int currentStreak;
  final bool canRecover;
  final String reasonText;
  final VoidCallback onRecover;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final missedDay =
        DateTime(missedDate.year, missedDate.month, missedDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final hoursSinceMissed = today.difference(missedDay).inHours;
    final hoursRemaining = 24 - hoursSinceMissed;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flame icon with warning color
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: canRecover ? Colors.orange[50] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                size: 48,
                color: canRecover ? Colors.orange[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              canRecover ? 'Seri Kırıldı! 🔥' : 'Seri Kırıldı 😔',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: canRecover ? Colors.orange[700] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Habit name and streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    habit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Streak info
            Text(
              '$currentStreak günlük serini kaybettin',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (canRecover) ...[
              // Recovery available
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'İyi haber! Serini kurtarabilirsin',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haftada bir kez kullanabileceğin seri kurtarma hakkın var. '
                      'Kullanırsan, dünü tamamlamış sayılacak ve $currentStreak günlük serin devam edecek.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[800],
                      ),
                    ),
                    if (hoursRemaining > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Kalan süre: $hoursRemaining saat',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recover button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onRecover,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.restore),
                  label: const Text(
                    'Seriyi Kurtar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Geç'),
                ),
              ),
            ] else ...[
              // Recovery not available
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kurtarma Kullanılamıyor',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reasonText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // New start button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onSkip,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text(
                    'Yeni Başlangıç Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
