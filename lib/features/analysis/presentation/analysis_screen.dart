import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'providers/analysis_provider.dart';
import 'widgets/daily_trend_chart.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text("Last 7 Days"),
              backgroundColor: Colors.black,
              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: analysisAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Invested Time Card
              Text("Invested Time", style: TextStyle(color: Colors.grey[600])),
              const Gap(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    data.totalInvestedFormatted,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Gap(8),
                  Text(
                    "${data.investedPercentage}%",
                    style: TextStyle(color: Colors.grey[500], fontSize: 18),
                  ),
                ],
              ),
              const Gap(24),

              // Total Spent Time
              Text("Spent Time", style: TextStyle(color: Colors.grey[600])),
              const Gap(4),
              Text(
                data.totalSpentFormatted,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(32),

              // Category Breakdown
              if (data.categoryBreakdown.isNotEmpty) ...[
                const Text(
                  "Top Categories",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                ...(data.categoryBreakdown.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                    .take(5)
                    .map((entry) {
                      final hours = entry.value ~/ 60;
                      final minutes = entry.value % 60;
                      final timeStr = '${hours}h ${minutes}m';
                      final percent = data.totalMinutes > 0
                          ? ((entry.value / data.totalMinutes) * 100).round()
                          : 0;
                      
                      return Column(
                        children: [
                          _buildCategoryRow(
                            _getCategoryIcon(entry.key),
                            entry.key,
                            timeStr,
                            '$percent%',
                          ),
                          const Gap(12),
                        ],
                      );
                    }),
                const Gap(24),
              ],

              // Daily Trend (Chart)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daily Trend",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.black, radius: 4),
                        const Gap(4),
                        Text("Invested", style: TextStyle(color: Colors.grey[800], fontSize: 12)),
                        const Gap(12),
                        CircleAvatar(backgroundColor: Colors.grey[400], radius: 4),
                        const Gap(4),
                        Text("Spent", style: TextStyle(color: Colors.grey[800], fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),
              SizedBox(
                height: 200,
                child: DailyTrendChart(entries: data.recentEntries),
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

  Widget _buildCategoryRow(IconData icon, String label, String duration, String percent) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[800]),
        const Gap(12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          duration,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(12),
        Text(
          percent,
          style: TextStyle(color: Colors.grey[500]),
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
