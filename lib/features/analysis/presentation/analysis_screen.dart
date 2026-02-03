import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'providers/analysis_provider.dart';
import 'providers/time_range_notifier.dart';
import 'widgets/time_trend_chart.dart';
import '../../ledger/presentation/widgets/month_view_modal.dart';
import '../../settings/presentation/settings_screen.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(filteredAnalysisDataProvider);
    final currentFilter = ref.watch(timeRangeFilterProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () => MonthViewModal.show(context),
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Buttons
              Row(
                children: [
                  Expanded(
                    child: _FilterButton(
                      label: "Last 7 Days",
                      isSelected: currentFilter == TimeRange.last7Days,
                      onTap: () => ref.read(timeRangeFilterProvider.notifier).setTimeRange(TimeRange.last7Days),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _FilterButton(
                      label: "Monthly",
                      isSelected: currentFilter == TimeRange.monthly,
                      onTap: () => ref.read(timeRangeFilterProvider.notifier).setTimeRange(TimeRange.monthly),
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Time Trend Chart (moved to top, replaces time overview)
              TimeTrendChart(
                entries: data.recentEntries,
                isLast7Days: currentFilter == TimeRange.last7Days,
                totalInvestedMinutes: data.totalInvestedMinutes,
                totalSpentMinutes: data.totalSpentMinutes,
                investedPercentage: data.investedPercentage,
              ),
              const Gap(24),

              // Category Breakdown
              Text(
                "Top Categories",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const Gap(10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800]! 
                        : Colors.grey[200]!, 
                    width: 1.5
                  ),
                ),
                child: data.categoryBreakdown.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.category_outlined, 
                                size: 48, 
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[700] 
                                    : Colors.grey[300]
                              ),
                              const Gap(12),
                              Text(
                                "No data found",
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[500] 
                                      : Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: (data.categoryBreakdown.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .take(5)
                            .map((entry) {
                              final hours = entry.value ~/ 60;
                              final minutes = entry.value % 60;
                              final timeStr = '${hours}h ${minutes}m';
                              final percent = data.totalMinutes > 0
                                  ? ((entry.value / data.totalMinutes) * 100).round()
                                  : 0;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildCategoryRow(
                                  context,
                                  _getCategoryIcon(entry.key),
                                  entry.key,
                                  timeStr,
                                  '$percent%',
                                ),
                              );
                            }).toList(),
                      ),
              ),

            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const Gap(16),
              Text('Error loading analysis: $err'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, IconData icon, String label, String duration, String percent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[800]),
        const Gap(12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Gap(12),
        Text(
          percent,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.laptop;
      case 'study':
        return Icons.school;
      case 'exercise':
        return Icons.fitness_center;
      case 'reading':
        return Icons.book;
      case 'gaming':
        return Icons.videogame_asset;
      case 'social':
        return Icons.people;
      case 'sleep':
        return Icons.bed;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}

// Filter Button Widget
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
