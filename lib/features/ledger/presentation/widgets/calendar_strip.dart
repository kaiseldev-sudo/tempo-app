import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/ledger_provider.dart';

class CalendarStrip extends ConsumerStatefulWidget {
  const CalendarStrip({super.key});

  @override
  ConsumerState<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends ConsumerState<CalendarStrip> {
  late ScrollController _scrollController;
  late List<DateTime> _dates;
  final int _historyDays = 30; // 30 days history
  final int _futureDays = 7; // 7 days future
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _generateDates();
    
    // Auto-scroll to today after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _generateDates() {
    final today = DateUtils.dateOnly(DateTime.now());
    _dates = List.generate(
      _historyDays + _futureDays + 1, // History + Today + Future
      (index) {
        return today.subtract(Duration(days: _historyDays - index));
      },
    );
  }

  void _scrollToToday() {
    // Calculate scroll offset to center 'Today'
    // Each item width = 56 + separator 10 = 66
    // Index of today is _historyDays
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 56.0 + 10.0; // width + gap
    final todayIndex = _historyDays;
    
    final offset = (todayIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateUtils.dateOnly(DateTime.now());

    return SizedBox(
      height: 90, // Slightly taller for better touch targets
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _dates.length,
        separatorBuilder: (_, index) => const Gap(10),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, today);
          final isPast = date.isBefore(today);

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).set(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isSelected 
                      ? Colors.black 
                      : (isToday ? Colors.black : Colors.grey[200]!),
                  width: isToday && !isSelected ? 2 : 1, // Thicker border for Today
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? "TDY" : DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white70 
                          : (isPast ? Colors.grey[400] : Colors.grey[600]), // Past dates dimmer
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : (isToday ? Colors.black : (isPast ? Colors.grey : Colors.black87)), 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  // Small dot for Today if not selected
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
