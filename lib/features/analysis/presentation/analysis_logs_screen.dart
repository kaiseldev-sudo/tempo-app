import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../ledger/domain/time_entry.dart';
import '../../ledger/presentation/widgets/entry_detail_modal.dart';

class AnalysisLogsScreen extends StatelessWidget {
  final List<TimeEntry> entries;

  const AnalysisLogsScreen({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Group entries by day
    final Map<DateTime, List<TimeEntry>> groupedEntries = {};
    for (var entry in entries) {
      final date = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "All Analysis Logs",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dayEntries = groupedEntries[date]!;
          final isToday = DateTime.now().year == date.year &&
              DateTime.now().month == date.month &&
              DateTime.now().day == date.day;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) ...[
                const Gap(32),
                Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), thickness: 1),
                const Gap(24),
              ],
              Row(
                children: [
                  Text(
                    isToday ? "Today" : DateFormat('EEEE, MMM d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyMedium?.color, // theme text color
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${dayEntries.length} entries",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              ...dayEntries.map((entry) => _buildCompactLogTile(context, entry)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactLogTile(BuildContext context, TimeEntry entry) {
    final isInvested = entry.type == 'invested';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    String durationText;
    final h = entry.durationMinutes ~/ 60;
    final m = entry.durationMinutes % 60;
    if (h > 0) {
      durationText = "${h}h${m > 0 ? " ${m}m" : ""}";
    } else {
      durationText = "${m}m";
    }

    return InkWell(
      onTap: () => EntryDetailModal.show(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isInvested ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 16,
              color: isInvested 
                  ? Theme.of(context).colorScheme.primary 
                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              durationText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
