import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Card showing monthly completion trend as a line chart.
class MonthlyLineChartCard extends StatelessWidget {
  const MonthlyLineChartCard({
    required this.monthlyData,
    super.key,
  });

  final List<MonthDataPoint> monthlyData;

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
              'Aylık Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: monthlyData.isEmpty
                  ? const Center(child: Text('Henüz veri yok'))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _createSpots(),
                            isCurved: true,
                            color: const Color(0xFF6C63FF),
                            barWidth: 3,
                            dotData: FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFF6C63FF),
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                            ),
                          ),
                        ],
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
                                    value.toInt() < monthlyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      monthlyData[value.toInt()].label,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            
                          ),
                          topTitles: const AxisTitles(
                            
                          ),
                        ),
                        gridData: FlGridData(
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

  List<FlSpot> _createSpots() {
    return monthlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.completionRate * 100);
    }).toList();
  }
}

/// Data model for monthly data point.
class MonthDataPoint {
  const MonthDataPoint({
    required this.label,
    required this.completionRate,
    required this.date,
  });

  final String label;
  final double completionRate;
  final DateTime date;
}
