import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ledger/domain/time_entry.dart';
import '../../../ledger/data/time_entry_repository.dart';
import '../../../../core/auth/auth_provider.dart';
import 'time_range_notifier.dart';

// Analysis Data Model
class AnalysisData {
  final int totalInvestedMinutes;
  final int totalSpentMinutes;
  final Map<String, int> categoryBreakdown;
  final List<TimeEntry> recentEntries;

  AnalysisData({
    required this.totalInvestedMinutes,
    required this.totalSpentMinutes,
    required this.categoryBreakdown,
    required this.recentEntries,
  });

  String get totalInvestedFormatted {
    final h = totalInvestedMinutes ~/ 60;
    final m = totalInvestedMinutes % 60;
    return '${h}h ${m}m';
  }

  String get totalSpentFormatted {
    final h = totalSpentMinutes ~/ 60;
    final m = totalSpentMinutes % 60;
    return '${h}h ${m}m';
  }

  int get totalMinutes => totalInvestedMinutes + totalSpentMinutes;

  int get investedPercentage {
    if (totalMinutes == 0) return 0;
    return ((totalInvestedMinutes / totalMinutes) * 100).round();
  }
}

// Analysis Provider (Last 7 days)
final analysisDataProvider = StreamProvider<AnalysisData>((ref) {
  final userId = ref.watch(userIdProvider);
  final repository = ref.read(timeEntryRepositoryProvider);

  if (userId == null) {
    return Stream.value(AnalysisData(
      totalInvestedMinutes: 0,
      totalSpentMinutes: 0,
      categoryBreakdown: {},
      recentEntries: [],
    ));
  }

  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  return repository.getEntriesByDateRange(userId, sevenDaysAgo, now).map((entries) {
    int investedMinutes = 0;
    int spentMinutes = 0;
    Map<String, int> categories = {};

    for (var entry in entries) {
      if (entry.type == 'invested') {
        investedMinutes += entry.durationMinutes;
      } else {
        spentMinutes += entry.durationMinutes;
      }

      categories[entry.category] = (categories[entry.category] ?? 0) + entry.durationMinutes;
    }

    return AnalysisData(
      totalInvestedMinutes: investedMinutes,
      totalSpentMinutes: spentMinutes,
      categoryBreakdown: categories,
      recentEntries: entries,
    );
  });
});


final timeEntryRepositoryProvider = Provider((ref) => TimeEntryRepository());

// Import time range filter from separate file
// (defined in time_range_notifier.dart)

// Analysis Provider with Filter
final filteredAnalysisDataProvider = StreamProvider<AnalysisData>((ref) {
  final userId = ref.watch(userIdProvider);
  final repository = ref.read(timeEntryRepositoryProvider);
  final timeRange = ref.watch(timeRangeFilterProvider);

  if (userId == null) {
    return Stream.value(AnalysisData(
      totalInvestedMinutes: 0,
      totalSpentMinutes: 0,
      categoryBreakdown: {},
      recentEntries: [],
    ));
  }

  final now = DateTime.now();
  final startDate = timeRange == TimeRange.last7Days
      ? now.subtract(const Duration(days: 7))
      : DateTime(now.year, now.month, 1); // First day of current month

  return repository.getEntriesByDateRange(userId, startDate, now).map((entries) {
    int investedMinutes = 0;
    int spentMinutes = 0;
    Map<String, int> categories = {};

    for (var entry in entries) {
      if (entry.type == 'invested') {
        investedMinutes += entry.durationMinutes;
      } else {
        spentMinutes += entry.durationMinutes;
      }

      categories[entry.category] = (categories[entry.category] ?? 0) + entry.durationMinutes;
    }

    return AnalysisData(
      totalInvestedMinutes: investedMinutes,
      totalSpentMinutes: spentMinutes,
      categoryBreakdown: categories,
      recentEntries: entries,
    );
  });
});
