import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/time_entry.dart';
import '../../data/time_entry_repository.dart';
import '../../../../core/auth/auth_provider.dart';

// Repository Provider
final timeEntryRepositoryProvider = Provider((ref) => TimeEntryRepository());

// Selected Date Provider
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void set(DateTime date) {
    state = date;
  }
}

// Calendar Focused Day Provider (tracks which month is visible in the calendar)
final calendarFocusedDayProvider = NotifierProvider<CalendarFocusedDayNotifier, DateTime>(CalendarFocusedDayNotifier.new);

class CalendarFocusedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void set(DateTime date) {
    state = date;
  }
}

// Ledger Entries Provider (Firestore Stream)
final ledgerEntriesProvider = StreamProvider.autoDispose<List<TimeEntry>>((ref) {
  final userId = ref.watch(userIdProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(timeEntryRepositoryProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.getEntriesByDate(userId, selectedDate);
});

// Add Time Entry Action
final addTimeEntryProvider = Provider((ref) {
  return (TimeEntry entry) async {
    final userId = ref.read(userIdProvider);
    final repository = ref.read(timeEntryRepositoryProvider);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await repository.saveTimeEntry(entry, userId);
  };
});

// Monthly Activity Provider
final monthlyActivityProvider = StreamProvider.autoDispose<Map<DateTime, DailyActivityData>>((ref) {
  final userId = ref.watch(userIdProvider);
  final focusedDay = ref.watch(calendarFocusedDayProvider);
  final repository = ref.watch(timeEntryRepositoryProvider);

  if (userId == null) {
    return Stream.value({});
  }

  final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0, 23, 59, 59);

  return repository.getEntriesByDateRange(userId, startOfMonth, endOfMonth).map((entries) {
    final Map<DateTime, DailyActivityTotals> dailyTotals = {};
    for (final entry in entries) {
      final date = DateTime(entry.startTime.year, entry.startTime.month, entry.startTime.day);
      final totals = dailyTotals[date] ?? DailyActivityTotals();
      
      if (entry.type == 'invested') {
        totals.investedMinutes += entry.durationMinutes;
      } else {
        totals.spentMinutes += entry.durationMinutes;
      }
      dailyTotals[date] = totals;
    }

    final Map<DateTime, DailyActivityData> activity = {};
    const totalMinutesPerDay = 24 * 60;
    
    dailyTotals.forEach((date, totals) {
      activity[date] = DailyActivityData(
        investedProgress: totals.investedMinutes / totalMinutesPerDay,
        spentProgress: totals.spentMinutes / totalMinutesPerDay,
      );
    });
    
    return activity;
  });
});

class DailyActivityTotals {
  int investedMinutes = 0;
  int spentMinutes = 0;
}

class DailyActivityData {
  final double investedProgress;
  final double spentProgress;

  DailyActivityData({
    required this.investedProgress,
    required this.spentProgress,
  });

  double get totalProgress => (investedProgress + spentProgress).clamp(0.0, 1.0);
}
