import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';

final ledgerBoxProvider = Provider<Box<TimeEntry>>((ref) {
  return Hive.box<TimeEntry>('time_entries');
});

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

final ledgerEntriesProvider = StreamProvider.autoDispose<List<TimeEntry>>((ref) async* {
  final box = ref.watch(ledgerBoxProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  List<TimeEntry> filter() {
    final entries = box.values.where((e) {
      return DateUtils.isSameDay(e.startTime, selectedDate);
    }).toList();
    
    // Sort by start time descending (newest first)
    entries.sort((a, b) => b.startTime.compareTo(a.startTime));
    return entries;
  }

  yield filter();

  await for (final _ in box.watch()) {
    yield filter();
  }
});
