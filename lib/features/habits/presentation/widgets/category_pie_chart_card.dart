import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Card showing category distribution as a pie chart.
class CategoryPieChartCard extends StatelessWidget {
  const CategoryPieChartCard({
    required this.categoryData,
    super.key,
  });

  final Map<String, int> categoryData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryData.isEmpty) {
      return Card(
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
              const SizedBox(height: 40),
              const Center(
                child: Text('Henüz veri yok'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final total = categoryData.values.reduce((a, b) => a + b);
    final sections = _createPieSections(categoryData, total);

    return Card(
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
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie chart
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryData.entries.map((entry) {
                        final color = _getColorForCategory(entry.key);
                        final percentage =
                            ((entry.value / total) * 100).round();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  List<PieChartSectionData> _createPieSections(
    Map<String, int> data,
    int total,
  ) {
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = _getColorForCategory(entry.key);

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.round()}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFFFF6B6B),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFFFCBF49),
    ];

    final hash = category.hashCode.abs();
    return colors[hash % colors.length];
  }
}
