import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habits_provider.dart';

/// Detailed view of a habit showing statistics and history with tabbed navigation.
class HabitDetailScreen extends ConsumerStatefulWidget {
  
  const HabitDetailScreen({required this.habitId, super.key});
  final String habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar with Tabs
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  floating: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
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
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteHabit(habit),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(habit.name),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getColorFromHex(habit.color),
                            _getColorFromHex(habit.color).withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          habit.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(icon: Icon(Icons.info_outline), text: 'Genel'),
                      Tab(icon: Icon(Icons.calendar_month), text: 'Takvim'),
                      Tab(icon: Icon(Icons.bar_chart), text: 'Grafik'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(habit),
                _buildCalendarTab(habit),
                _buildChartTab(habit),
              ],
            ),
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
  // TAB 1: General Info
  // ============================================================================
  
  Widget _buildGeneralTab(Habit habit) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatisticsSection(habit),
          const SizedBox(height: 24),
          
          // Habit Details
          Text(
            'Alışkanlık Detayları',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: habit.category,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          
          if (habit.description != null && habit.description!.isNotEmpty) ...[
            _buildInfoCard(
              icon: Icons.description_outlined,
              label: 'Açıklama',
              value: habit.description!,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
          ],
          
          _buildInfoCard(
            icon: Icons.repeat,
            label: 'Sıklık',
            value: _getFrequencyText(habit.frequency),
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          
          _buildInfoCard(
            icon: Icons.calendar_today,
            label: 'Oluşturulma Tarihi',
            value: habit.createdAt.toFormattedDate(),
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'Son Aktiviteler',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRecentActivityList(habit),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency.type) {
      case FrequencyType.daily:
        final config = frequency.config;
        if (config['everyDay'] == true) {
          return 'Her gün';
        } else {
          final days = config['specificDays'] as List?;
          return days != null && days.isNotEmpty
              ? 'Belirli günler (${days.length} gün)'
              : 'Günlük';
        }
      case FrequencyType.weekly:
        final times = frequency.config['timesPerWeek'] as int? ?? 1;
        return 'Haftada $times kez';
      default:
        return 'Özel';
    }
  }
  
  Widget _buildRecentActivityList(Habit habit) {
    final logsAsync = ref.watch(
      FutureProvider<List<HabitLog>>((ref) async {
        final result = await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
        if (result is Success<List<HabitLog>>) {
          return result.data.take(5).toList();
        }
        return [];
      }).future,
    );
    
    return FutureBuilder<List<HabitLog>>(
      future: logsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final logs = snapshot.data ?? [];
        
        if (logs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Henüz kayıt yok'),
              ),
            ),
          );
        }
        
        return Column(
          children: logs.map((log) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: log.completed 
                      ? Colors.green[100] 
                      : Colors.orange[100],
                  child: Icon(
                    log.completed ? Icons.check : Icons.skip_next,
                    color: log.completed ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                title: Text(log.date.toFormattedDate()),
                subtitle: log.note != null 
                    ? Text(log.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : log.skipped && log.skipReason != null
                        ? Text('Atlandı: ${log.skipReason}')
                        : null,
                trailing: log.quality != null
                    ? Chip(
                        label: Text(
                          log.quality == LogQuality.excellent 
                              ? 'Mükemmel' 
                              : log.quality == LogQuality.good 
                                  ? 'İyi' 
                                  : 'Minimal',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: log.quality == LogQuality.excellent
                            ? Colors.green[100]
                            : log.quality == LogQuality.good
                                ? Colors.blue[100]
                                : Colors.grey[200],
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  // ============================================================================
  // TAB 2: Calendar
  // ============================================================================
  
  Widget _buildCalendarTab(Habit habit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _buildCalendar(habit),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedDay != null) _buildDayDetails(habit, _selectedDay!),
        ],
      ),
    );
  }
  
  Widget _buildDayDetails(Habit habit, DateTime day) {
    final logsAsync = ref.watch(
      FutureProvider<HabitLog?>((ref) async {
        final result = await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
        if (result is Success<List<HabitLog>>) {
          return result.data.firstWhere(
            (log) => isSameDay(log.date, day),
            orElse: () => HabitLog(
              id: '',
              habitId: '',
              userId: '',
              date: day,
              completed: false,
              skipped: false,
              createdAt: DateTime.now(),
            ),
          );
        }
        return null;
      }).future,
    );
    
    return FutureBuilder<HabitLog?>(
      future: logsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final log = snapshot.data;
        
        if (log == null || log.id.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined, 
                      size: 48, 
                      color: Colors.grey[400]
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu gün için kayıt yok',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: log.completed 
                          ? Colors.green[100] 
                          : Colors.orange[100],
                      child: Icon(
                        log.completed ? Icons.check : Icons.skip_next,
                        color: log.completed ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.toFormattedDate(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            log.completed ? 'Tamamlandı' : 'Atlandı',
                            style: TextStyle(
                              color: log.completed ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (log.quality != null)
                      Chip(
                        label: Text(
                          log.quality == LogQuality.excellent 
                              ? 'Mükemmel' 
                              : log.quality == LogQuality.good 
                                  ? 'İyi' 
                                  : 'Minimal',
                        ),
                        backgroundColor: log.quality == LogQuality.excellent
                            ? Colors.green[100]
                            : log.quality == LogQuality.good
                                ? Colors.blue[100]
                                : Colors.grey[200],
                      ),
                  ],
                ),
                if (log.note != null && log.note!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Not:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(log.note!),
                ],
                if (log.skipReason != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Atlama Nedeni:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(log.skipReason!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  // ============================================================================
  // TAB 3: Chart
  // ============================================================================
  
  Widget _buildChartTab(Habit habit) {
    final logsAsync = ref.watch(
      FutureProvider<List<HabitLog>>((ref) async {
        final result = await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
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
          return const Center(child: CircularProgressIndicator());
        }
        
        final logs = snapshot.data ?? [];
        
        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz veri yok',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alışkanlığınızı takip etmeye başladığınızda grafikler burada görünecek',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 30-Day Trend Chart
              Text(
                '30 Günlük Trend',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildLineChart(logs, habit),
                ),
              ),
              const SizedBox(height: 24),
              
              // Weekly Comparison Chart
              Text(
                'Haftalık Karşılaştırma',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBarChart(logs),
                ),
              ),
              const SizedBox(height: 24),
              
              // Statistics Summary
              Text(
                'İstatistikler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatsSummary(logs),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLineChart(List<HabitLog> logs, Habit habit) {
    // Get last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 29));
    
    // Create data points for last 30 days
    final dataPoints = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      final log = logs.firstWhere(
        (l) => isSameDay(l.date, date),
        orElse: () => HabitLog(
          id: '',
          habitId: '',
          userId: '',
          date: date,
          completed: false,
          skipped: false,
          createdAt: DateTime.now(),
        ),
      );
      
      // 1 for completed, 0 for not completed
      dataPoints.add(FlSpot(i.toDouble(), log.completed ? 1 : 0));
    }
    
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final date = thirtyDaysAgo.add(Duration(days: value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('❌', style: TextStyle(fontSize: 12));
                  if (value == 1) return const Text('✅', style: TextStyle(fontSize: 12));
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: _getColorFromHex(habit.color),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: spot.y == 1 ? Colors.green : Colors.red,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: _getColorFromHex(habit.color).withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = thirtyDaysAgo.add(Duration(days: spot.x.toInt()));
                  final status = spot.y == 1 ? '✅ Tamamlandı' : '❌ Yapılmadı';
                  return LineTooltipItem(
                    '${date.day}/${date.month}\n$status',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBarChart(List<HabitLog> logs) {
    // Group by week (last 4 weeks)
    final now = DateTime.now();
    final weekData = <int, int>{};
    
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (3 - i) * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final completedCount = logs.where((log) {
        return log.completed &&
            log.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            log.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;
      
      weekData[i] = completedCount;
    }
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (weekData.values.isEmpty ? 7 : weekData.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} gün\ntamamlandı',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const weeks = ['4 hafta önce', '3 hafta önce', '2 hafta önce', 'Bu hafta'];
                  if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        weeks[value.toInt()],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          barGroups: weekData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.blue,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildStatsSummary(List<HabitLog> logs) {
    final completedLogs = logs.where((l) => l.completed).toList();
    final totalDays = logs.length;
    final completedDays = completedLogs.length;
    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).toStringAsFixed(1) : '0.0';
    
    // Calculate average quality
    final qualityLogs = completedLogs.where((l) => l.quality != null).toList();
    final avgQuality = qualityLogs.isEmpty
        ? 'N/A'
        : (qualityLogs.map((l) {
            switch (l.quality!) {
              case LogQuality.excellent: return 3;
              case LogQuality.good: return 2;
              case LogQuality.minimal: return 1;
            }
          }).reduce((a, b) => a + b) / qualityLogs.length).toStringAsFixed(1);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              icon: Icons.check_circle,
              label: 'Toplam Tamamlama',
              value: completedDays.toString(),
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.percent,
              label: 'Başarı Oranı',
              value: '$completionRate%',
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.star,
              label: 'Ortalama Kalite',
              value: avgQuality,
              color: Colors.amber,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.skip_next,
              label: 'Atlanan Günler',
              value: logs.where((l) => l.skipped).length.toString(),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // ============================================================================
  // Shared Widgets
  // ============================================================================
  
  Widget _buildStatisticsSection(Habit habit) {
    final statsAsync = ref.watch(habitStatisticsProvider(habit.id));
    
    return statsAsync.when(
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                value: stats.totalCompletions.toString(),
                label: 'Tamamlama',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                value: stats.currentStreak.toString(),
                label: 'Mevcut Seri',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                value: stats.longestStreak.toString(),
                label: 'En Uzun Seri',
                color: Colors.amber,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
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
        ),
      ),
    );
  }
  
  Widget _buildCalendar(Habit habit) {
    final logsAsync = ref.watch(
      FutureProvider<List<HabitLog>>((ref) async {
        final result = await ref.read(habitRepositoryProvider).getLogsForHabit(habit.id);
        return result is Success<List<HabitLog>> ? result.data : [];
      }).future,
    );
    
    return FutureBuilder<List<HabitLog>>(
      future: logsAsync,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final logDates = logs
            .where((log) => log.completed)
            .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
            .toSet();
        
        return TableCalendar(
          firstDay: habit.createdAt,
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              if (logDates.contains(normalizedDay)) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
  
  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true && mounted) {
      final success = await ref.read(habitActionProvider.notifier).deleteHabit(habit.id);
      
      if (success && mounted) {
        context.showSuccessSnackBar('Alışkanlık silindi');
        Navigator.of(context).pop(true);
      } else if (mounted) {
        final error = ref.read(habitActionProvider).error;
        context.showErrorSnackBar(error ?? 'Silme başarısız');
      }
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