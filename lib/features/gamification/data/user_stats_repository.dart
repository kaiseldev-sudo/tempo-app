import 'package:cloud_firestore/cloud_firestore.dart';
import '../../gamification/data/user_stats.dart';

class UserStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user stats document reference
  DocumentReference<Map<String, dynamic>> _getUserStatsDoc(String userId) {
    return _firestore.collection('users').doc(userId).collection('stats').doc('current');
  }

  // Save or Update User Stats
  Future<void> saveUserStats(UserStats stats, String userId) async {
    try {
      await _getUserStatsDoc(userId).set({
        'currentXp': stats.currentXp,
        'totalFocusMinutes': stats.totalFocusMinutes,
        'tasksCompleted': stats.tasksCompleted,
        'sessionsCompleted': stats.sessionsCompleted,
        'dailyStreak': stats.dailyStreak,
        'unlockedBadgeIds': stats.unlockedBadgeIds,
        'lastLoginMs': stats.lastLoginMs,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user stats: $e');
    }
  }

  // Get User Stats
  Stream<UserStats?> getUserStats(String userId) {
    return _getUserStatsDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserStats(
        currentXp: data['currentXp'] as int? ?? 0,
        totalFocusMinutes: data['totalFocusMinutes'] as int? ?? 0,
        tasksCompleted: data['tasksCompleted'] as int? ?? 0,
        sessionsCompleted: data['sessionsCompleted'] as int? ?? 0,
        dailyStreak: data['dailyStreak'] as int? ?? 0,
        unlockedBadgeIds: List<String>.from(data['unlockedBadgeIds'] ?? []),
        lastLoginMs: data['lastLoginMs'] as int? ?? 0,
      );
    });
  }

  // Initialize User Stats (first time)
  Future<void> initializeUserStats(String userId) async {
    final doc = await _getUserStatsDoc(userId).get();
    if (!doc.exists) {
      await saveUserStats(UserStats(), userId);
    }
  }

  // Record XP Transaction
  Future<void> recordXpTransaction({
    required String userId,
    required int xpAmount,
    required String source,
    required String description,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('xp_transactions')
          .add({
        'amount': xpAmount,
        'source': source,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record XP transaction: $e');
    }
  }

  // Record Badge Unlock
  Future<void> recordBadgeUnlock({
    required String userId,
    required String badgeId,
    required String badgeTitle,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badge_unlocks')
          .doc(badgeId)
          .set({
        'badgeId': badgeId,
        'badgeTitle': badgeTitle,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record badge unlock: $e');
    }
  }
}
