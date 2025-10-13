import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/presentation/providers/habits_provider.dart';

/// Statistics screen showing habit analytics and insights.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Giriş Yapılmadı',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('İstatistikleri görmek için giriş yapın'),
                ],
              ),
            );
          }

          return _buildStatistics(context, ref, user.id);
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, WidgetRef ref, String userId) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider(userId));

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Henüz alışkanlık yok',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('İstatistikleri görmek için alışkanlık oluşturun'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overview Card
            _buildOverviewCard(context, habits, userId, ref),
            const SizedBox(height: 16),

            // Category Distribution
            _buildCategoryChart(context, habits),
            const SizedBox(height: 16),

            // Completion Trend (Last 7 days)
            _buildCompletionTrendChart(context, habits, userId, ref),
            const SizedBox(height: 16),

            // Individual Habit Stats
            _buildHabitsList(context, habits, ref),
            const SizedBox(height: 80),
          ],
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    List<Habit> habits,
    String userId,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    // Calculate overall stats
    const totalCompletions = 0;
    final totalActiveHabits =
        habits.where((h) => h.status == HabitStatus.active).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Bakış',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  icon: Icons.fitness_center,
                  value: totalActiveHabits.toString(),
                  label: 'Aktif Alışkanlık',
                  color: Colors.blue,
                ),
                _buildOverviewItem(
                  icon: Icons.check_circle,
                  value: totalCompletions.toString(),
                  label: 'Toplam Tamamlama',
                  color: Colors.green,
                ),
                _buildOverviewItem(
                  icon: Icons.local_fire_department,
                  value: '0',
                  label: 'Ortalama Seri',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryChart(BuildContext context, List<Habit> habits) {
    final theme = Theme.of(context);

    // Count habits by category
    final categoryCount = <String, int>{};
    for (final habit in habits) {
      categoryCount[habit.category] = (categoryCount[habit.category] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Dağılımı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: categoryCount.isEmpty
                  ? const Center(child: Text('Veri yok'))
                  : PieChart(
                      PieChartData(
                        sections: _buildPieSections(categoryCount),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryCount.entries.map((entry) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: _getCategoryColor(entry.key),
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  label: Text(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
    ];

    var colorIndex = 0;
    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.value.toString(),
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCompletionTrendChart(
    BuildContext context,
    List<Habit> habits,
    String userId,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 7 Gün Tamamlanma Trendi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            'Pzt',
                            'Sal',
                            'Çar',
                            'Per',
                            'Cum',
                            'Cmt',
                            'Paz'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Text(days[value.toInt()],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateMockTrendData(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateMockTrendData() {
    // TODO: Get real data from repository
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 5),
      const FlSpot(2, 4),
      const FlSpot(3, 6),
      const FlSpot(4, 5),
      const FlSpot(5, 7),
      const FlSpot(6, 6),
    ];
  }

  Widget _buildHabitsList(
    BuildContext context,
    List<Habit> habits,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alışkanlık İstatistikleri',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...habits.map((habit) => _buildHabitStatItem(habit, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStatItem(Habit habit, WidgetRef ref) {
    final statsAsync = ref.watch(habitStatisticsProvider(habit.id));

    return statsAsync.when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColorFromHex(habit.color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(habit.icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${stats.totalCompletions} tamamlama • ${stats.currentStreak} gün seri',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.currentStreak}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Sağlık': Colors.red,
      'Spor': Colors.blue,
      'Üretkenlik': Colors.orange,
      'Sosyal': Colors.purple,
      'Öğrenme': Colors.green,
      'Mali': Colors.teal,
      'Kişisel Gelişim': Colors.pink,
      'Yaratıcılık': Colors.amber,
      'Diğer': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
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
