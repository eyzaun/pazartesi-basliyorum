import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../providers/habit_timer_notifier.dart';
import '../providers/timer_session_providers.dart';
import '../widgets/circle_progress_painter.dart';
import '../widgets/detailed_checkin_sheet.dart';

/// Timer screen for timed habits
class HabitTimerScreen extends ConsumerStatefulWidget {
  const HabitTimerScreen({
    required this.habit,
    super.key,
  });

  final Habit habit;

  @override
  ConsumerState<HabitTimerScreen> createState() => _HabitTimerScreenState();
}

class _HabitTimerScreenState extends ConsumerState<HabitTimerScreen> {
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(habitTimerWithHabitProvider(widget.habit));
    final timerNotifier =
        ref.read(habitTimerWithHabitProvider(widget.habit).notifier);

    return PopScope(
      canPop: timerState.status != TimerStatus.running,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && timerState.status == TimerStatus.running) {
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(widget.habit.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.habit.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Target Display
                if (timerState.target != null) ...[
                  Text(
                    'Hedef: ${_formatDuration(timerState.target!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Timer Circle
                _buildTimerCircle(timerState),

                const SizedBox(height: 32),

                // Control Buttons
                _buildControlButtons(timerState, timerNotifier),

                const SizedBox(height: 24),

                // Quick Actions
                if (timerState.status == TimerStatus.running ||
                    timerState.status == TimerStatus.paused) ...[
                  _buildQuickActions(timerNotifier),
                  const SizedBox(height: 24),
                ],

                // Session History
                _buildTodaySessions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(HabitTimerState state) {
    final progress = state.progress;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          CustomPaint(
            size: const Size(280, 280),
            painter: CircleProgressPainter(
              progress: progress,
              backgroundColor: Colors.grey.shade200,
              progressColor: _getProgressColor(progress),
              strokeWidth: 20,
            ),
          ),

          // Time Display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(state.elapsed),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              if (state.target != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    HabitTimerState state,
    HabitTimerNotifier notifier,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.status == TimerStatus.running
                ? notifier.pause
                : state.status == TimerStatus.paused
                    ? notifier.resume
                    : notifier.start,
            icon: Icon(
              state.status == TimerStatus.running
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 28,
            ),
            label: Text(
              state.status == TimerStatus.running
                  ? 'Duraklat'
                  : state.status == TimerStatus.paused
                      ? 'Devam Et'
                      : 'Başlat',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: state.status == TimerStatus.running
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ),
        if (state.status != TimerStatus.idle) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmStop(state, notifier),
              icon: const Icon(Icons.check_circle, size: 28),
              label: const Text('Tamamla', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions(HabitTimerNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Ayar:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickButton('+1 dk', () => notifier.addTime(60)),
            const SizedBox(width: 12),
            _buildQuickButton('+5 dk', () => notifier.addTime(300)),
            const SizedBox(width: 12),
            _buildQuickButton('-1 dk', () => notifier.addTime(-60)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildTodaySessions() {
    final sessions = ref.watch(todaySessionsProvider(widget.habit.id));

    return sessions.when(
      data: (sessionList) {
        if (sessionList.isEmpty) return const SizedBox();

        final totalSeconds = sessionList.fold<int>(
          0,
          (sum, s) => sum + s.actualSeconds,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bugün:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${sessionList.length} seans • ${_formatMinutes(totalSeconds)} toplam',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.8) return Colors.blue;
    if (progress < 1.0) return Colors.green;
    return Colors.purple;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatMinutes(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes dk';
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zamanlayıcı Çalışıyor'),
        content: const Text(
          'Zamanlayıcı hala çalışıyor. Çıkmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _confirmStop(
    HabitTimerState state,
    HabitTimerNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktiviteyi Tamamla?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Geçen süre: ${_formatDuration(state.elapsed)}'),
            if (state.target != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hedef: ${_formatDuration(state.target!)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Alışkanlığınız tamamlanmış olarak işaretlenecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Devam Et'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Tamamla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.stop();
      
      if (!mounted) return;

      // Format duration as note
      final totalSeconds = state.elapsed.inSeconds;
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      final durationNote = minutes > 0 
          ? '$minutes dakika ${seconds > 0 ? "$seconds saniye" : ""}'.trim()
          : '$seconds saniye';
      
      // Show completion sheet with duration note (BEFORE closing timer screen)
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DetailedCheckInSheet(
          habit: widget.habit,
          initialNote: durationNote,
        ),
      );
      
      // Close timer screen and return result to calling screen
      if (mounted) {
        Navigator.pop(context, result); // Return result even if null (user cancelled)
      }
    }
  }
}
