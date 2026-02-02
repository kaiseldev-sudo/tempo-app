import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';

class DailyTrendChart extends StatelessWidget {
  final List<TimeEntry> entries;

  const DailyTrendChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Group entries by day of week (Mon, Tue, ...)
    // For MVP, just random data or basic aggregation if available
    // Assuming simple mock data for trend visual since user wants "screens" created quickly
    
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 16,
          barTouchData: BarTouchData(enabled: false),
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
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'S'; break;
                    case 1: text = 'M'; break;
                    case 2: text = 'T'; break;
                    case 3: text = 'W'; break;
                    case 4: text = 'T'; break;
                    case 5: text = 'F'; break;
                    case 6: text = 'S'; break;
                    default: text = '';
                  }
                  return SideTitleWidget(meta: meta, child: Text(text, style: style));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 4, 2), // Mon: 4h invested, 2h spent
            _makeGroupData(1, 6, 3),
            _makeGroupData(2, 8, 1),
            _makeGroupData(3, 14, 2), // High work day
            _makeGroupData(4, 14, 2),
            _makeGroupData(5, 7, 5),
            _makeGroupData(6, 0, 8),  // Lazy Sunday
          ],
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
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.grey[400], // Spent
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
