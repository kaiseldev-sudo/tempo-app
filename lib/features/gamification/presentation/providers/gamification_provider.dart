
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/game_constants.dart';
import '../../domain/badge_model.dart';
import '../../data/user_stats.dart';

class LevelState {
  final int currentLevel;
  final String title;
  final double progress;
  final int currentXp;
  final int dailyStreak;
  final int unlockedBadgeCount;
  final List<Badge> newlyUnlockedBadges;
  final bool leveledUp;

  LevelState({
    required this.currentLevel,
    required this.title,
    required this.progress,
    required this.currentXp,
    this.dailyStreak = 0,
    this.unlockedBadgeCount = 0,
    this.newlyUnlockedBadges = const [],
    this.leveledUp = false,
  });
}

final userStatsBoxProvider = Provider<Box<UserStats>>((ref) {
  return Hive.box<UserStats>('user_stats');
});

final gamificationProvider = NotifierProvider<GamificationNotifier, LevelState>(GamificationNotifier.new);

class GamificationNotifier extends Notifier<LevelState> {
  late Box<UserStats> _box;
  late UserStats _stats;

  @override
  LevelState build() {
    _box = ref.watch(userStatsBoxProvider);
    _initStats();
    return _initialState();
  }

  LevelState _initialState() {
     // We will update this in _initStats logic actually, or just return default then update.
     // Better: Calculate state from _stats immediately if possible.
     // But _initStats might be async? No, Hive box is already open.
     if (_box.isEmpty) {
       _stats = UserStats();
       _box.add(_stats);
     } else {
       _stats = _box.values.first;
     }
     
     final level = GameConstants.getLevelForXp(_stats.currentXp);
     final progress = GameConstants.getProgressToNextLevel(_stats.currentXp);
     return LevelState(
       currentLevel: level.level,
       title: level.title,
       progress: progress,
       currentXp: _stats.currentXp,
       dailyStreak: _stats.dailyStreak,
       unlockedBadgeCount: _stats.unlockedBadgeIds.length,
     );
  }

  void _initStats() {
    // Moved logic to build/initialState
  }

  void _updateState({List<Badge> newBadges = const [], bool leveledUp = false}) {
    final level = GameConstants.getLevelForXp(_stats.currentXp);
    final progress = GameConstants.getProgressToNextLevel(_stats.currentXp);
    
    state = LevelState(
      currentLevel: level.level,
      title: level.title,
      progress: progress,
      currentXp: _stats.currentXp,
      dailyStreak: _stats.dailyStreak,
      unlockedBadgeCount: _stats.unlockedBadgeIds.length,
      newlyUnlockedBadges: newBadges,
      leveledUp: leveledUp,
    );
  }

  // CORE LOGIC: Process Action (Session/Task Complete)
  Future<void> processAction({required String type, int? minutes}) async {
    // 1. Add Base XP
    int xpToAdd = GameConstants.xpSources[type] ?? 0;
    
    // 2. Update Stats
    if (type == 'focus_session') {
      _stats.sessionsCompleted += 1;
      _stats.totalFocusMinutes += (minutes ?? 0);
    } else if (type == 'task_completed') {
      _stats.tasksCompleted += 1;
    }
    
    // 3. Check Badges
    List<Badge> unlocked = [];
    for (var badge in BadgeRepository.allBadges) {
      if (!_stats.unlockedBadgeIds.contains(badge.id)) {
        if (_evaluateUnlockCondition(badge)) {
          unlocked.add(badge);
          _stats.unlockedBadgeIds.add(badge.id);
          xpToAdd += badge.xp; // Add Badge XP
        }
      }
    }

    // 4. Level Up Check
    final oldLevel = GameConstants.getLevelForXp(_stats.currentXp).level;
    _stats.currentXp += xpToAdd;
    final newLevel = GameConstants.getLevelForXp(_stats.currentXp).level;
    bool leveledUp = newLevel > oldLevel;

    // 5. Save & Emit
    await _stats.save();
    _updateState(newBadges: unlocked, leveledUp: leveledUp);
  }

  bool _evaluateUnlockCondition(Badge badge) {
    switch (badge.unlockType) {
      case 'session_count':
        return _stats.sessionsCompleted >= badge.unlockValue;
      case 'daily_streak':
        return _stats.dailyStreak >= badge.unlockValue;
      case 'single_session_minutes':
         // Simplified logic
        return false; 
      case 'task_completed':
        return _stats.tasksCompleted >= badge.unlockValue;
      default:
        return false;
    }
  }
}
