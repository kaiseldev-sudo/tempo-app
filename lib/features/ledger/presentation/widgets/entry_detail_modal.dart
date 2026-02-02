import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';
import 'package:tempo/features/gamification/domain/badge_model.dart';

class EntryDetailModal extends StatelessWidget {
  final TimeEntry entry;

  const EntryDetailModal({super.key, required this.entry});

  static Future<void> show(BuildContext context, TimeEntry entry) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EntryDetailModal(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInvested = entry.type == 'invested';
    
    // Format duration
    String durationText;
    final h = entry.durationMinutes ~/ 60;
    final m = entry.durationMinutes % 60;
    if (h > 0) {
      durationText = "${h}h${m > 0 ? " ${m}m" : ""}";
    } else {
      durationText = "${m}m";
    }

    final dateText = DateFormat('EEEE, MMM d, y').format(entry.startTime);
    final timeText = DateFormat('h:mm a').format(entry.startTime);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "Entry Details",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const Gap(24),

          // Main Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isInvested ? Colors.black : Colors.grey[50],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isInvested ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          entry.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: isInvested ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isInvested ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isInvested ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSubStat(
                      label: "DURATION",
                      value: durationText,
                      isDark: isInvested,
                    ),
                    _buildSubStat(
                      label: "TIME",
                      value: timeText,
                      isDark: isInvested,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),

          // Date Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const Gap(8),
              Text(
                dateText,
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Gap(24),

          // XP Earned (If any)
          if (entry.xpEarned != null && entry.xpEarned! > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 28),
                  const Gap(16),
                  const Expanded(
                    child: Text(
                      "XP Earned",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Text(
                    "+${entry.xpEarned} XP",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          
          if (entry.unlockedBadgeIds != null && entry.unlockedBadgeIds!.isNotEmpty) ...[
            const Gap(24),
            const Text(
              "Badges Unlocked",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const Gap(12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: entry.unlockedBadgeIds!.map((id) {
                final badge = BadgeRepository.getBadgeById(id);
                if (badge == null) return const SizedBox.shrink();
                return SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(badge.icon, color: Colors.black, size: 24),
                      ),
                      const Gap(4),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          const Gap(32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Close"),
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildSubStat({required String label, required String value, required bool isDark}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.grey[500],
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
