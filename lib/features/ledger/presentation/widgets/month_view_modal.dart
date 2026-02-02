import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gap/gap.dart';
import 'package:tempo/features/ledger/presentation/providers/ledger_provider.dart';
import 'activity_ring.dart';

class MonthViewModal extends ConsumerStatefulWidget {
  const MonthViewModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MonthViewModal(),
    );
  }

  @override
  ConsumerState<MonthViewModal> createState() => _MonthViewModalState();
}

class _MonthViewModalState extends ConsumerState<MonthViewModal> {
  late DateTime _focusedDay;
  
  @override
  void initState() {
    super.initState();
    // Initialize with currently selected date from provider
    _focusedDay = ref.read(selectedDateProvider);
    // Sync with focused day provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarFocusedDayProvider.notifier).set(_focusedDay);
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(ref.read(selectedDateProvider), selectedDay)) {
      // Update the global selected date
      ref.read(selectedDateProvider.notifier).set(selectedDay);
      setState(() {
        _focusedDay = focusedDay;
      });
      // Update global focused day provider
      ref.read(calendarFocusedDayProvider.notifier).set(focusedDay);
      // Close modal after selection
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final monthlyActivity = ref.watch(monthlyActivityProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65, // Occupy ~2/3 of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Date",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Gap(8),

          // Calendar
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                ref.read(calendarFocusedDayProvider.notifier).set(focusedDay);
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(fontWeight: FontWeight.w500),
                weekendTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                weekendStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final activity = monthlyActivity.value?[DateTime(day.year, day.month, day.day)];
                  return Center(
                    child: ActivityRing(
                      investedProgress: activity?.investedProgress ?? 0.0,
                      spentProgress: activity?.spentProgress ?? 0.0,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
                holidayBuilder: (context, day, focusedDay) {
                  final activity = monthlyActivity.value?[DateTime(day.year, day.month, day.day)];
                  return Center(
                    child: ActivityRing(
                      investedProgress: activity?.investedProgress ?? 0.0,
                      spentProgress: activity?.spentProgress ?? 0.0,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final activity = monthlyActivity.value?[DateTime(day.year, day.month, day.day)];
                  return Center(
                    child: ActivityRing(
                      investedProgress: activity?.investedProgress ?? 0.0,
                      spentProgress: activity?.spentProgress ?? 0.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // "Today" shortcut button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final today = DateTime.now();
                ref.read(selectedDateProvider.notifier).set(today);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Jump to Today",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
