import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Card showing weekly completion rate as a bar chart.
class WeeklyBarChartCard extends StatelessWidget {
  const WeeklyBarChartCard({
    required this.weeklyData,
    super.key,
  });

  final List<DayCompletionData> weeklyData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haftalık Tamamlanma Oranı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: weeklyData.isEmpty
                  ? const Center(child: Text('Henüz veri yok'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barGroups: _createBarGroups(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < weeklyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      weeklyData[value.toInt()].dayLabel,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = data.completionRate * 100;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: _getColorForPercentage(data.completionRate),
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getColorForPercentage(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

/// Data model for daily completion.
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
