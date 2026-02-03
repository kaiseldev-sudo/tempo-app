import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';
import 'package:intl/intl.dart';

class DailyTrendChart extends StatelessWidget {
  final List<TimeEntry> entries;

  const DailyTrendChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // 1. Generate last 7 days starting from today (in reverse, so most recent is on the right)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    // 2. Initialize and Aggregate data
    final Map<DateTime, Map<String, double>> dailyData = {
      for (var date in last7Days) date: {'invested': 0.0, 'spent': 0.0}
    };

    for (var entry in entries) {
      final entryDate = DateTime(entry.startTime.year, entry.startTime.month, entry.startTime.day);
      if (dailyData.containsKey(entryDate)) {
        final hours = entry.durationMinutes / 60.0;
        if (entry.type == 'invested') {
          dailyData[entryDate]!['invested'] = (dailyData[entryDate]!['invested'] ?? 0) + hours;
        } else {
          dailyData[entryDate]!['spent'] = (dailyData[entryDate]!['spent'] ?? 0) + hours;
        }
      }
    }

    // 3. Find maxY for dynamic scaling
    double maxVal = 0;
    for (var data in dailyData.values) {
      if (data['invested']! > maxVal) maxVal = data['invested']!;
      if (data['spent']! > maxVal) maxVal = data['spent']!;
    }
    // Set a minimum maxY of 8.0 if everything is 0, otherwise pad by 25%
    final maxY = maxVal == 0 ? 8.0 : (maxVal * 1.25);

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final type = rodIndex == 0 ? "Invested" : "Spent";
                final hours = rod.toY;
                final h = hours.toInt();
                final m = ((hours - h) * 60).round();
                return BarTooltipItem(
                  "$type\n${h}h ${m}m",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  final index = value.toInt();
                  if (index < 0 || index >= last7Days.length) return const SizedBox();
                  
                  final date = last7Days[index];
                  final label = DateFormat('E').format(date).substring(0, 1);
                  
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(label, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final date = last7Days[index];
            final data = dailyData[date]!;
            return _makeGroupData(index, data['invested']!, data['spent']!);
          }),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.black, // Invested
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.grey[400], // Spent
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
