import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../gamification/presentation/widgets/gamification_stats_summary.dart';
import 'widgets/time_entry_card.dart';
import 'widgets/month_view_modal.dart';
import 'providers/ledger_provider.dart';
import '../../settings/presentation/settings_screen.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(ledgerEntriesProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM d, y').format(selectedDate),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () => MonthViewModal.show(context), icon: const Icon(Icons.calendar_month)),
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
      body: Column(
        children: [
          const Gap(8),
          const GamificationStatsSummary(),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(right: 24, left: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5), // Shadow pointing upwards
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header inside the container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Row(
                      children: [
                        Text(
                          "Daily Log",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('E, MMM d').format(selectedDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[50]),
                  Expanded(
                    child: entriesAsync.when(
                      data: (entries) {
                        if (entries.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time_rounded, size: 48, color: Colors.grey[200]),
                                const Gap(16),
                                Text(
                                  "No entries yet",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: entries.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[100],
                            indent: 60, // Align with the start of the text (skipping the icon)
                          ),
                          itemBuilder: (context, index) {
                            return TimeEntryCard(entry: entries[index]);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text("Error: $err")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
