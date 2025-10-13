import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card showing habit completion heatmap calendar.
class HeatmapCalendarCard extends StatelessWidget {
  const HeatmapCalendarCard({
    required this.heatmapData,
    super.key,
  });

  final Map<DateTime, double> heatmapData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2); // Last 3 months

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivite Haritası',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Son 90 gün',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmap(context, startDate, now),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, DateTime start, DateTime end) {
    final days = <Widget>[];
    final current = DateTime(start.year, start.month, start.day);

    // Add day labels (S M T W T F S)
    final dayLabels = [
      'P',
      'P',
      'S',
      'Ç',
      'P',
      'C',
      'C'
    ]; // Turkish abbreviations
    days.add(
      SizedBox(
        width: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dayLabels
              .map((label) => Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                  ))
              .toList(),
        ),
      ),
    );

    // Group days by week
    final weeks = <List<DateTime>>[];
    final currentWeek = <DateTime>[];

    // Fill initial padding
    final startWeekday = current.weekday % 7;
    for (var i = 0; i < startWeekday; i++) {
      currentWeek.add(DateTime(1970)); // Placeholder
    }

    var date = current;
    while (date.isBefore(end) || date.isAtSameMomentAs(end)) {
      currentWeek.add(date);
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
      date = date.add(const Duration(days: 1));
    }

    // Add remaining days
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(DateTime(1970)); // Placeholder
      }
      weeks.add(currentWeek);
    }

    // Build week columns
    for (final week in weeks) {
      days.add(
        Column(
          children: week.map((day) => _buildDayCell(context, day)).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days,
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    if (date.year == 1970) {
      // Placeholder
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.all(2),
      );
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final rate = heatmapData[normalizedDate] ?? 0.0;
    final color = _getHeatmapColor(rate);

    return Tooltip(
      message: '${DateFormat('d MMM').format(date)}: ${(rate * 100).round()}%',
      child: Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          'Az',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final rate = index * 0.25;
          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getHeatmapColor(rate),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'Çok',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(double rate) {
    if (rate == 0) return Colors.grey[200]!;
    if (rate < 0.25) return const Color(0xFFE8F5E9);
    if (rate < 0.5) return const Color(0xFFA5D6A7);
    if (rate < 0.75) return const Color(0xFF66BB6A);
    return const Color(0xFF2E7D32);
  }
}
