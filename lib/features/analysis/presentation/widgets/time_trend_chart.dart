import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../ledger/domain/time_entry.dart';

class TimeTrendChart extends StatefulWidget {
  final List<TimeEntry> entries;
  final bool isLast7Days;
  final int totalInvestedMinutes;
  final int totalSpentMinutes;
  final int investedPercentage;

  const TimeTrendChart({
    super.key,
    required this.entries,
    required this.isLast7Days,
    required this.totalInvestedMinutes,
    required this.totalSpentMinutes,
    required this.investedPercentage,
  });

  @override
  State<TimeTrendChart> createState() => _TimeTrendChartState();
}

class _TimeTrendChartState extends State<TimeTrendChart> {
  int? touchedIndex;

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final investedBarColor = Theme.of(context).colorScheme.primary;
    final spentBarColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Summary Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invested Time",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatTime(widget.totalInvestedMinutes),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          "${widget.investedPercentage}%",
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spent Time",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatTime(widget.totalSpentMinutes),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          "${100 - widget.investedPercentage}%",
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[100], thickness: 1),
          const Gap(16),
          
          // Chart Section
          Text(
            "Time Trend",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "No data available",
                          style: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(chartData),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => isDark ? Colors.grey[800]! : Colors.black87,
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = chartData[group.x.toInt()];
                            final isInvested = rodIndex == 0;
                            final minutes = isInvested 
                                ? data.investedMinutes 
                                : data.spentMinutes;
                            
                            final hours = minutes ~/ 60;
                            final mins = minutes % 60;
                            final timeStr = hours > 0
                                ? '${hours}h ${mins}m'
                                : '${mins}m';
                            
                            final label = isInvested ? 'Invested' : 'Spent';
                            
                            return BarTooltipItem(
                              '$label\n$timeStr',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return _buildBottomTitle(value.toInt(), chartData, isDark);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 60,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              final hours = value ~/ 60;
                              return Text(
                                '${hours}h',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 60,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.investedMinutes.toDouble(),
                              color: investedBarColor,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: data.spentMinutes.toDouble(),
                              color: spentBarColor,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(investedBarColor, "Invested", isDark),
              const SizedBox(width: 16),
              _buildLegendItem(spentBarColor, "Spent", isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTitle(int index, List<DayData> chartData, bool isDark) {
    if (index < 0 || index >= chartData.length) {
      return const SizedBox.shrink();
    }

    final date = chartData[index].date;
    final label = widget.isLast7Days
        ? _getDayLabel(date)
        : '${date.day}';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  List<DayData> _prepareChartData() {
    final now = DateTime.now();
    final Map<String, DayData> dataMap = {};

    // Initialize all days with zero values
    if (widget.isLast7Days) {
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final key = _dateKey(date);
        dataMap[key] = DayData(
          date: date,
          investedMinutes: 0,
          spentMinutes: 0,
        );
      }
    } else {
      // Monthly view - current month
      final lastDay = DateTime(now.year, now.month + 1, 0);
      
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(now.year, now.month, day);
        final key = _dateKey(date);
        dataMap[key] = DayData(
          date: date,
          investedMinutes: 0,
          spentMinutes: 0,
        );
      }
    }

    // Populate with actual data
    for (var entry in widget.entries) {
      final key = _dateKey(entry.startTime);
      if (dataMap.containsKey(key)) {
        if (entry.type == 'invested') {
          dataMap[key]!.investedMinutes += entry.durationMinutes;
        } else {
          dataMap[key]!.spentMinutes += entry.durationMinutes;
        }
      }
    }

    // Convert to sorted list
    final sortedData = dataMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedData;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _getMaxY(List<DayData> chartData) {
    double maxValue = 0;
    for (var data in chartData) {
      final max = data.investedMinutes > data.spentMinutes
          ? data.investedMinutes
          : data.spentMinutes;
      if (max > maxValue) {
        maxValue = max.toDouble();
      }
    }
    
    // Add 20% padding and round to nearest hour
    final paddedMax = maxValue * 1.2;
    final roundedMax = ((paddedMax / 60).ceil() * 60).toDouble();
    
    return roundedMax > 0 ? roundedMax : 120; // Minimum 2 hours
  }
}

class DayData {
  final DateTime date;
  int investedMinutes;
  int spentMinutes;

  DayData({
    required this.date,
    required this.investedMinutes,
    required this.spentMinutes,
  });
}
