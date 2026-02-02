import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';
import 'entry_detail_modal.dart';

class TimeEntryCard extends StatelessWidget {
  final TimeEntry entry;

  const TimeEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isInvested = entry.type == 'invested';
    final startTimeStr = DateFormat('h:mm a').format(entry.startTime);
    
    // Format duration: 60m -> 1h, 90m -> 1h 30m
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isInvested ? Colors.black : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInvested ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isInvested ? Colors.white : Colors.grey[600],
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      Text(
                        entry.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const Gap(8),
                      Text(
                        "•",
                        style: TextStyle(color: Colors.grey[300], fontSize: 10),
                      ),
                      const Gap(8),
                      Text(
                        startTimeStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              durationText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
