import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habits_provider.dart';
import '../widgets/category_pie_chart_card.dart';
import '../widgets/heatmap_calendar_card.dart';
import '../widgets/monthly_line_chart_card.dart';
import '../widgets/statistics_overview_card.dart';
import '../widgets/top_habits_card.dart';
import '../widgets/weekly_bar_chart_card.dart';

/// Statistics screen showing user's habit performance and insights.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  TimeRange _selectedRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authStateProvider).value;
    final userId = authUser?.id ?? '';

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    final habitsAsync = ref.watch(habitsProvider(userId));
    final logsAsync = ref.watch(todayLogsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Paylaş',
            onPressed: () {
              habitsAsync.whenData((habits) {
                logsAsync.whenData((logs) {
                  final stats =
                      _calculateStatistics(habits, logs, _selectedRange);
                  _shareStatistics(stats, habits.length);
                });
              });
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) => logsAsync.when(
          data: (logs) {
            final stats = _calculateStatistics(habits, logs, _selectedRange);

            return CustomScrollView(
              slivers: [
                // Time range selector
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildTimeRangeChip(TimeRange.week, '7 Gün'),
                        const SizedBox(width: 8),
                        _buildTimeRangeChip(TimeRange.month, '30 Gün'),
                        const SizedBox(width: 8),
                        _buildTimeRangeChip(TimeRange.quarter, '90 Gün'),
                        const SizedBox(width: 8),
                        _buildTimeRangeChip(TimeRange.all, 'Tümü'),
                      ],
                    ),
                  ),
                ),

                // Overall statistics card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StatisticsOverviewCard(
                      totalHabits: stats.totalHabits,
                      completedToday: stats.completedToday,
                      currentStreak: stats.currentStreak,
                      completionRate: stats.completionRate,
                      totalCompletions: stats.totalCompletions,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Top 3 habits
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TopHabitsCard(
                      topHabits: stats.topHabits,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Category breakdown
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori Dağılımı',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (stats.categoryBreakdown.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Henüz veri yok'),
                                ),
                              )
                            else
                              ...stats.categoryBreakdown.entries.map((entry) {
                                final percentage =
                                    (entry.value / stats.totalHabits * 100)
                                        .round();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text(
                                            '$percentage%',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: entry.value / stats.totalHabits,
                                        backgroundColor: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Category pie chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategoryPieChartCard(
                      categoryData: stats.categoryBreakdown,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Weekly bar chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WeeklyBarChartCard(
                      data: _generateWeeklyData(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Monthly line chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MonthlyLineChartCard(
                      monthlyData: _generateMonthlyData(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Heatmap calendar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HeatmapCalendarCard(
                      heatmapData: _generateHeatmapData(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Hata: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildTimeRangeChip(TimeRange range, String label) {
    final isSelected = _selectedRange == range;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedRange = range);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  OverallStatistics _calculateStatistics(
    List<Habit> habits,
    List<HabitLog> todayLogs,
    TimeRange range,
  ) {
    final activeHabits =
        habits.where((h) => h.status == HabitStatus.active).toList();
    final completedToday = todayLogs.where((l) => l.completed).length;

    // Calculate category breakdown
    final categoryBreakdown = <String, int>{};
    for (final habit in activeHabits) {
      categoryBreakdown[habit.category] =
          (categoryBreakdown[habit.category] ?? 0) + 1;
    }

    // Calculate top habits (by completion count)
    // TODO: This should fetch actual completion data from logs
    final topHabits = activeHabits.take(3).map((habit) {
      return TopHabitData(
        habit: habit,
        completionCount: 10, // Placeholder
        completionRate: 0.75, // Placeholder
      );
    }).toList();

    return OverallStatistics(
      totalHabits: activeHabits.length,
      completedToday: completedToday,
      currentStreak: 5, // TODO: Calculate from logs
      completionRate:
          activeHabits.isEmpty ? 0 : completedToday / activeHabits.length,
      totalCompletions: 50, // TODO: Calculate from logs
      categoryBreakdown: categoryBreakdown,
      topHabits: topHabits,
    );
  }

  /// Generate weekly data for bar chart (last 7 days).
  List<DayCompletionData> _generateWeeklyData() {
    final now = DateTime.now();
    final weeklyData = <DayCompletionData>[];

    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      final dayLabel = dayLabels[date.weekday - 1];

      // TODO: Calculate actual completion rate from logs
      final rate = (i % 3 == 0) ? 0.8 : ((i % 2 == 0) ? 0.6 : 0.4);

      weeklyData.add(
        DayCompletionData(
          dayLabel: dayLabel,
          completionRate: rate,
          date: date,
        ),
      );
    }

    return weeklyData;
  }

  /// Generate monthly data for line chart (last 30 days, grouped by week).
  List<MonthDataPoint> _generateMonthlyData() {
    final now = DateTime.now();
    final monthlyData = <MonthDataPoint>[];

    // Group by weeks (4 weeks)
    for (var i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final label = 'H${4 - i}'; // H1, H2, H3, H4

      // TODO: Calculate actual completion rate from logs
      final rate = 0.6 + (i * 0.1); // Gradually increasing

      monthlyData.add(
        MonthDataPoint(
          label: label,
          completionRate: rate,
          date: weekStart,
        ),
      );
    }

    return monthlyData;
  }

  /// Generate heatmap data for calendar (last 90 days).
  Map<DateTime, double> _generateHeatmapData() {
    final now = DateTime.now();
    final heatmapData = <DateTime, double>{};

    for (var i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // TODO: Calculate actual completion rate from logs
      // Random data for now
      final rate =
          (i % 5 == 0) ? 0.0 : ((i % 3 == 0) ? 1.0 : 0.5 + (i % 2) * 0.25);

      heatmapData[normalizedDate] = rate;
    }

    return heatmapData;
  }

  /// Share statistics as text.
  Future<void> _shareStatistics(
      OverallStatistics stats, int totalHabits,) async {
    final completionPercentage =
        (stats.completionRate * 100).toStringAsFixed(1);

    // Build top habits text
    final topHabitsBuffer = StringBuffer();
    for (var i = 0; i < stats.topHabits.length && i < 3; i++) {
      final habit = stats.topHabits[i];
      topHabitsBuffer.write(
          '\n  ${i + 1}. ${habit.habit.name} - ${habit.completionRate.toStringAsFixed(0)}%',);
    }

    final text = '''
🔥 Pazartesi Başlıyorum İstatistiklerim

📊 Genel Durum:
  • Toplam Alışkanlık: $totalHabits
  • Bugün Tamamlanan: ${stats.completedToday}
  • Mevcut Seri: ${stats.currentStreak} gün
  • Tamamlanma Oranı: $completionPercentage%
  • Toplam Tamamlama: ${stats.totalCompletions}
${topHabitsBuffer.isNotEmpty ? '\n🏆 En İyi Alışkanlıklarım:$topHabitsBuffer' : ''}

Hedeflerine ulaşmak için Pazartesi Başlıyorum ile başla! 🚀
''';

    await Share.share(
      text,
      subject: 'Alışkanlık İstatistiklerim',
    );
  }
}

/// Time range enum for statistics filtering.
enum TimeRange {
  week,
  month,
  quarter,
  all,
}

/// Overall statistics data model.
class OverallStatistics {
  const OverallStatistics({
    required this.totalHabits,
    required this.completedToday,
    required this.currentStreak,
    required this.completionRate,
    required this.totalCompletions,
    required this.categoryBreakdown,
    required this.topHabits,
  });

  final int totalHabits;
  final int completedToday;
  final int currentStreak;
  final double completionRate;
  final int totalCompletions;
  final Map<String, int> categoryBreakdown;
  final List<TopHabitData> topHabits;
}

/// Top habit data model.
class TopHabitData {
  const TopHabitData({
    required this.habit,
    required this.completionCount,
    required this.completionRate,
  });

  final Habit habit;
  final int completionCount;
  final double completionRate;
}

/// Day completion data model for bar chart.
class DayCompletionData {
  const DayCompletionData({
    required this.dayLabel,
    required this.completionRate,
    required this.date,
  });

  final String dayLabel;
  final double completionRate;
  final DateTime date;
}
