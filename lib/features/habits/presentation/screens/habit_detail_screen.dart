import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/time_override.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habits_provider.dart';
import 'habit_activity_detail_screen.dart';

/// Modern habit detail screen with beautiful UI and comprehensive analytics
class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({required this.habitId, super.key});
  final String habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitProvider(widget.habitId));

    return habitAsync.when(
      data: (habit) {
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: CustomErrorWidget(
              message: 'Alışkanlık bulunamadı',
              onRetry: () => ref.invalidate(habitProvider(widget.habitId)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              _buildModernAppBar(habit),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatisticsOverview(habit),
                    const SizedBox(height: 16),
                    _buildStreakSection(habit),
                    const SizedBox(height: 16),
                    _buildProgressChart(habit),
                    const SizedBox(height: 16),
                    _buildRecentActivity(habit),
                    const SizedBox(height: 16),
                    _buildHabitInfo(habit),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(habitProvider(widget.habitId)),
        ),
      ),
    );
  }

  // ============================================================================
  // Modern App Bar with Gradient Hero
  // ============================================================================

  Widget _buildModernAppBar(Habit habit) {
    final baseColor = _getColorFromHex(habit.color);
    
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: baseColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _shareProgress(habit),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            final result = await Navigator.of(context).pushNamed(
              AppRouter.habitEdit,
              arguments: widget.habitId,
            );
            if (result == true && mounted) {
              ref.invalidate(habitProvider(widget.habitId));
            }
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'delete') {
              _deleteHabit(habit);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                baseColor.withValues(alpha: 0.7),
                baseColor.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with glassmorphic background
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          habit.icon,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Habit name
                      Text(
                        habit.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category & Frequency chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildGlassChip(
                            icon: Icons.category_outlined,
                            label: habit.category,
                          ),
                          _buildGlassChip(
                            icon: Icons.repeat,
                            label: _getFrequencyText(habit.frequency),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Statistics Overview Cards
  // ============================================================================

  Widget _buildStatisticsOverview(Habit habit) {
    final statsAsync = ref.watch(habitStatisticsProvider(habit.id));
    final scoreAsync = habit.frequency.type == FrequencyType.custom
        ? ref.watch(habitScoreProvider(habit.id))
        : null;

    return statsAsync.when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      icon: Icons.check_circle_rounded,
                      value: stats.totalCompletions.toString(),
                      label: 'Tamamlanan',
                      color: const Color(0xFF4CAF50),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Show score percentage for custom frequency habits, otherwise completion rate
                  Expanded(
                    child: scoreAsync != null
                        ? scoreAsync.when(
                            data: (score) {
                              if (score == null || score.maxScore == 0) {
                                return _buildModernStatCard(
                                  icon: Icons.trending_up_rounded,
                                  value: '${_calculateCompletionRate(stats)}%',
                                  label: 'Başarı Oranı',
                                  color: const Color(0xFF2196F3),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                                  ),
                                );
                              }
                              return _buildModernStatCard(
                                icon: Icons.auto_graph_rounded,
                                value: '${score.percentage}%',
                                label: 'İlerleme Puanı',
                                color: const Color(0xFF2196F3),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                                ),
                              );
                            },
                            loading: () => _buildModernStatCard(
                              icon: Icons.trending_up_rounded,
                              value: '-%',
                              label: 'Yükleniyor...',
                              color: const Color(0xFF2196F3),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                              ),
                            ),
                            error: (_, __) => _buildModernStatCard(
                              icon: Icons.trending_up_rounded,
                              value: '${_calculateCompletionRate(stats)}%',
                              label: 'Başarı Oranı',
                              color: const Color(0xFF2196F3),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                              ),
                            ),
                          )
                        : _buildModernStatCard(
                            icon: Icons.trending_up_rounded,
                            value: '${_calculateCompletionRate(stats)}%',
                            label: 'Başarı Oranı',
                            color: const Color(0xFF2196F3),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Streak Section with Fire Animation
  // ============================================================================

  Widget _buildStreakSection(Habit habit) {
    final statsAsync = ref.watch(habitStatisticsProvider(habit.id));

    return statsAsync.when(
      data: (stats) {
        final hasStreak = stats.currentStreak > 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: hasStreak
                    ? [
                        const Color(0xFFFF6B35),
                        const Color(0xFFFF8C42),
                      ]
                    : [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: hasStreak
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
                      : Colors.black12,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Fire icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasStreak
                          ? Icons.local_fire_department_rounded
                          : Icons.local_fire_department_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasStreak ? '🔥 Harika gidiyorsun!' : 'Seri başlat!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${stats.currentStreak}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'gün seri',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (stats.longestStreak > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'En uzun: ${stats.longestStreak} gün 🏆',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 120),
      error: (error, stack) => const SizedBox(),
    );
  }

  // ============================================================================
  // Progress Chart Section
  // ============================================================================

  Widget _buildProgressChart(Habit habit) {
    final logsAsync = ref.watch(
      FutureProvider<List<HabitLog>>((ref) async {
        final result =
            await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
        if (result is Success<List<HabitLog>>) {
          return result.data;
        }
        return [];
      }).future,
    );

    return FutureBuilder<List<HabitLog>>(
      future: logsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final logs = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Son 30 Gün',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${logs.where((l) => l.completed && _isInLast30Days(l.date)).length}/30',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (logs.isEmpty)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Henüz veri yok',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildModernHeatmap(logs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeatmap(List<HabitLog> logs) {
    final now = TimeOverride.now();
    final weeks = <List<DateTime>>[];
    
    // Build last 5 weeks
    for (var week = 4; week >= 0; week--) {
      final weekDays = <DateTime>[];
      for (var day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: week * 7 + (6 - day)));
        weekDays.add(date);
      }
      weeks.add(weekDays);
    }

    return Column(
      children: [
        // Day labels
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['P', 'S', 'Ç', 'P', 'C', 'C', 'P']
                .map((day) => SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        ...weeks.asMap().entries.map((entry) {
          final weekIndex = entry.key;
          final week = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    'H${weekIndex + 1}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ...week.map((date) {
                  final log = logs.firstWhere(
                    (l) => _isSameDay(l.date, date),
                    orElse: () => HabitLog(
                      id: '',
                      habitId: '',
                      userId: '',
                      date: date,
                      completed: false,
                      createdAt: DateTime.now(),
                    ),
                  );

                  final isCompleted = log.completed;
                  final isFuture = date.isAfter(now);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFuture
                                ? Colors.grey[200]
                                : isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============================================================================
  // Recent Activity Timeline
  // ============================================================================

  Widget _buildRecentActivity(Habit habit) {
    final logsAsync = ref.watch(
      FutureProvider<List<HabitLog>>((ref) async {
        final result =
            await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
        if (result is Success<List<HabitLog>>) {
          return result.data.take(10).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
        }
        return [];
      }).future,
    );

    return FutureBuilder<List<HabitLog>>(
      future: logsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son Aktiviteler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...logs.map((log) => _buildActivityItem(habit, log)),
                  if (logs.length >= 10) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to full activity list
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Tüm Aktiviteleri Gör'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Habit habit, HabitLog log) {
    final isCompleted = log.completed;
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HabitActivityDetailScreen(
              habit: habit,
              log: log,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.cancel_outlined,
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Date and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatActivityDate(log.date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (log.note != null && log.note!.isNotEmpty)
                    Text(
                      log.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    )
                  else if (log.skipReason != null)
                    Text(
                      log.skipReason!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // Quality badge
            if (log.quality != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQualityColor(log.quality!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getQualityEmoji(log.quality!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Habit Info Card
  // ============================================================================

  Widget _buildHabitInfo(Habit habit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alışkanlık Bilgileri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (habit.description != null && habit.description!.isNotEmpty) ...[
                _buildInfoRow(
                  icon: Icons.description_outlined,
                  label: 'Açıklama',
                  value: habit.description!,
                  color: Colors.blue,
                ),
                const Divider(height: 24),
              ],
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Başlangıç',
                value: DateFormat('d MMMM yyyy', 'tr_TR').format(habit.createdAt),
                color: Colors.purple,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.repeat,
                label: 'Sıklık',
                value: _getFrequencyText(habit.frequency),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF6C63FF);
    }
  }

  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency.type) {
      case FrequencyType.daily:
        final config = frequency.config;
        if (config['everyDay'] == true) {
          return 'Her gün';
        } else {
          final days = config['specificDays'] as List?;
          if (days != null && days.isNotEmpty) {
            final dayNames = days.map((day) {
              switch (day) {
                case 'Monday':
                  return 'Pazartesi';
                case 'Tuesday':
                  return 'Salı';
                case 'Wednesday':
                  return 'Çarşamba';
                case 'Thursday':
                  return 'Perşembe';
                case 'Friday':
                  return 'Cuma';
                case 'Saturday':
                  return 'Cumartesi';
                case 'Sunday':
                  return 'Pazar';
                default:
                  return day.toString();
              }
            }).join(', ');
            return 'Belirli günler: $dayNames';
          }
          return 'Günlük';
        }
      case FrequencyType.weekly:
        final times = frequency.config['timesPerWeek'] as int? ?? 1;
        return 'Haftada $times kez';
      case FrequencyType.custom:
        final periodDays = frequency.config['periodDays'] as int? ?? 1;
        final timesInPeriod = frequency.config['timesInPeriod'] as int? ?? 1;
        return '$periodDays günde $timesInPeriod kez';
      default:
        return 'Özel';
    }
  }

  String _getQualityEmoji(LogQuality quality) {
    switch (quality) {
      case LogQuality.excellent:
        return '😊';
      case LogQuality.good:
        return '🙂';
      case LogQuality.minimal:
        return '😐';
    }
  }

  Color _getQualityColor(LogQuality quality) {
    switch (quality) {
      case LogQuality.excellent:
        return const Color(0xFF4CAF50);
      case LogQuality.good:
        return const Color(0xFF2196F3);
      case LogQuality.minimal:
        return Colors.orange;
    }
  }

  String _formatActivityDate(DateTime date) {
    final now = TimeOverride.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) {
      return 'Bugün';
    } else if (diff == 1) {
      return 'Dün';
    } else if (diff < 7) {
      return '$diff gün önce';
    } else {
      return DateFormat('d MMM', 'tr_TR').format(date);
    }
  }

  int _calculateCompletionRate(dynamic stats) {
    if (stats.totalCompletions == 0) return 0;
    
    final now = TimeOverride.now();
    final startDate = TimeOverride.now().subtract(const Duration(days: 30));
    final daysPassed = now.difference(startDate).inDays + 1;
    
    return ((stats.totalCompletions / daysPassed) * 100).round();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInLast30Days(DateTime date) {
    final now = TimeOverride.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return date.isAfter(thirtyDaysAgo) && date.isBefore(now.add(const Duration(days: 1)));
  }

  Future<void> _shareProgress(Habit habit) async {
    // TODO: Implement share functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşma özelliği yakında eklenecek')),
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Alışkanlığı Sil'),
          content: Text(
            '"${habit.name}" alışkanlığını silmek istediğinizden emin misiniz?\n\n'
            'Bu işlem geri alınamaz ve tüm geçmiş kayıtlar silinecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(habitActionProvider.notifier).deleteHabit(habit.id);

      if (success && mounted) {
        context.showSuccessSnackBar('Alışkanlık silindi');
        Navigator.of(context).pop(true);
      } else if (mounted) {
        final error = ref.read(habitActionProvider).error;
        context.showErrorSnackBar(error ?? 'Silme başarısız');
      }
    }
  }
}
