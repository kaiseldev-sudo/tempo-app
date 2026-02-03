import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeRange { last7Days, monthly }

class TimeRangeNotifier extends Notifier<TimeRange> {
  @override
  TimeRange build() => TimeRange.last7Days;

  void setTimeRange(TimeRange range) {
    state = range;
  }
}

final timeRangeFilterProvider = NotifierProvider<TimeRangeNotifier, TimeRange>(
  TimeRangeNotifier.new,
);
