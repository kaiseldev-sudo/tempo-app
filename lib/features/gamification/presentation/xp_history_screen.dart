import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'providers/gamification_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class XPHistoryScreen extends ConsumerWidget {
  const XPHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(xpHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'XP History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const Gap(16),
                  Text(
                    'No XP history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Complete tasks or focus sessions to earn XP!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: history.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) {
              final transaction = history[index];
              final timestamp = transaction['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('MMM d, yyyy • h:mm a').format(timestamp.toDate())
                  : 'Recent';
              final amount = transaction['amount'] as int? ?? 0;
              final description = transaction['description'] as String? ?? 'Activity';
              final source = transaction['source'] as String? ?? '';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSourceColor(source).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSourceIcon(source),
                        color: _getSourceColor(source),
                        size: 20,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+$amount XP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _getSourceColor(source),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'focus_session':
        return Icons.timer_outlined;
      case 'task_completed':
        return Icons.check_circle_outline;
      case 'daily_login':
        return Icons.login_rounded;
      case 'badge_unlock':
        return Icons.emoji_events_outlined;
      default:
        return Icons.stars_rounded;
    }
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'focus_session':
        return Colors.blue;
      case 'task_completed':
        return Colors.green;
      case 'daily_login':
        return Colors.orange;
      case 'badge_unlock':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }
}
