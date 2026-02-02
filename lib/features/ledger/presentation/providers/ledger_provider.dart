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
