import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';

class TimeEntryCard extends StatelessWidget {
  final TimeEntry entry;

  const TimeEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isInvested = entry.type == 'invested';
    
    // Format duration: 60m -> 1h, 90m -> 1h 30m
    String durationText;
    final h = entry.durationMinutes ~/ 60;
    final m = entry.durationMinutes % 60;
    if (h > 0) {
      durationText = "${h}h${m > 0 ? " ${m}m" : ""}";
    } else {
      durationText = "${m}m";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isInvested ? Colors.black : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInvested ? Icons.trending_up : Icons.trending_down,
                color: isInvested ? Colors.white : Colors.black54,
                size: 20,
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
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    entry.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Text(
              durationText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
