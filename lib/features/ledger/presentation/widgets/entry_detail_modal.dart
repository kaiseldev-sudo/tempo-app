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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: textColor,
              ),
              Expanded(
                child: Text(
                  "Entry Details",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
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
              color: isInvested 
                  ? primaryColor 
                  : (isDark ? Colors.grey[800] : Colors.grey[50]),
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
                            color: isInvested ? onPrimaryColor : textColor,
                          ),
                        ),
                        Text(
                          entry.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: isInvested 
                                ? onPrimaryColor.withValues(alpha: 0.7) 
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isInvested ? onPrimaryColor.withValues(alpha: 0.2) : (isDark ? Colors.black26 : Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isInvested ? onPrimaryColor : textColor,
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
                      textColor: isInvested ? onPrimaryColor : textColor,
                      subTextColor: isInvested 
                          ? onPrimaryColor.withValues(alpha: 0.7) 
                          : (isDark ? Colors.grey[400]! : Colors.grey[500]!),
                    ),
                    _buildSubStat(
                      label: "TIME",
                      value: timeText,
                      textColor: isInvested ? onPrimaryColor : textColor,
                      subTextColor: isInvested 
                          ? onPrimaryColor.withValues(alpha: 0.7) 
                          : (isDark ? Colors.grey[400]! : Colors.grey[500]!),
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
                  Expanded(
                    child: Text(
                      "XP Earned",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
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
            Text(
              "Badges Unlocked",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey),
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
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(badge.icon, color: textColor, size: 24),
                      ),
                      const Gap(4),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
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
            // Theme default style should handle colors, but enforcing inverted
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
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

  Widget _buildSubStat({
    required String label, 
    required String value, 
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: subTextColor,
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
            color: textColor,
          ),
        ),
      ],
    );
  }
}
