import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/time_entry.dart';

class TimeEntryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'time_entries';

  // Get user-specific collection reference
  CollectionReference<Map<String, dynamic>> _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  // Create or Update Time Entry
  Future<void> saveTimeEntry(TimeEntry entry, String userId) async {
    try {
      await _getUserCollection(userId).doc(entry.id).set({
        'id': entry.id,
        'title': entry.title,
        'category': entry.category,
        'type': entry.type,
        'durationMinutes': entry.durationMinutes,
        'startTime': Timestamp.fromDate(entry.startTime),
        'notes': entry.notes,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save time entry: $e');
    }
  }

  // Get all entries for a specific date
  Stream<List<TimeEntry>> getEntriesByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _getUserCollection(userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TimeEntry(
          id: data['id'] as String,
          title: data['title'] as String,
          category: data['category'] as String,
          type: data['type'] as String,
          durationMinutes: data['durationMinutes'] as int,
          startTime: (data['startTime'] as Timestamp).toDate(),
          notes: data['notes'] as String?,
        );
      }).toList();
    });
  }

  // Get all entries (for analysis)
  Stream<List<TimeEntry>> getAllEntries(String userId) {
    return _getUserCollection(userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TimeEntry(
          id: data['id'] as String,
          title: data['title'] as String,
          category: data['category'] as String,
          type: data['type'] as String,
          durationMinutes: data['durationMinutes'] as int,
          startTime: (data['startTime'] as Timestamp).toDate(),
          notes: data['notes'] as String?,
        );
      }).toList();
    });
  }

  // Delete Time Entry
  Future<void> deleteTimeEntry(String entryId, String userId) async {
    try {
      await _getUserCollection(userId).doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete time entry: $e');
    }
  }

  // Get entries for a date range (for analysis)
  Stream<List<TimeEntry>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getUserCollection(userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TimeEntry(
          id: data['id'] as String,
          title: data['title'] as String,
          category: data['category'] as String,
          type: data['type'] as String,
          durationMinutes: data['durationMinutes'] as int,
          startTime: (data['startTime'] as Timestamp).toDate(),
          notes: data['notes'] as String?,
        );
      }).toList();
    });
  }
}
