import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../ledger/presentation/providers/ledger_provider.dart';
import 'widgets/daily_trend_chart.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For MVP, analysis logic is placeholder. We'd aggregate data properly in a real app.
    // Let's assume user has some data.
    
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
              label: const Text("Current"),
              backgroundColor: Colors.black,
              labelStyle: const TextStyle(color: Colors.white),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Time Card
            Text("Spent Time", style: TextStyle(color: Colors.grey[600])),
            const Gap(4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "36h 15m",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Gap(8),
                Text("42%", style: TextStyle(color: Colors.grey[500], fontSize: 18)),
              ],
            ),
            const Gap(4),
            Row(
              children: [
                const Icon(Icons.arrow_drop_down, color: Colors.red),
                Text(
                  "2h 30m than last week",
                  style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Gap(32),

            // Category Breakdown (Top 3)
            _buildCategoryRow(Icons.laptop, "Work", "20h 30m", "22%"),
            const Gap(16),
            _buildCategoryRow(Icons.phone_iphone, "Gaming", "10h 30m", "11%"),
            const Gap(16),
            _buildCategoryRow(Icons.bed, "Sleep", "5h 15m", "5%"),
            
            const Gap(48),

            // Daily Trend (Chart)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Trend", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            const SizedBox(
              height: 200,
              child: DailyTrendChart(entries: []),
            ),
          ],
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
}
