import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_constants.dart';
import '../../domain/badge_model.dart';
import '../../data/user_stats.dart';
import '../../data/user_stats_repository.dart';
import '../../../../core/auth/auth_provider.dart';

class LevelState {
  final int currentLevel;
  final String title;
  final double progress;
  final int currentXp;
  final int dailyStreak;
  final String lastCheckInDate;
  final int unlockedBadgeCount;
  final List<Badge> newlyUnlockedBadges;
  final bool leveledUp;

  LevelState({
    required this.currentLevel,
    required this.title,
    required this.progress,
    required this.currentXp,
    this.dailyStreak = 0,
    this.lastCheckInDate = '',
    this.unlockedBadgeCount = 0,
    this.newlyUnlockedBadges = const [],
    this.leveledUp = false,
  });
}

// Repository Provider
final userStatsRepositoryProvider = Provider((ref) => UserStatsRepository());

// User Stats Stream Provider
final userStatsStreamProvider = StreamProvider<UserStats?>((ref) {
  final userId = ref.watch(userIdProvider);
  final repository = ref.watch(userStatsRepositoryProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  return repository.getUserStats(userId);
});

// XP History Provider
final xpHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = ref.watch(userIdProvider);
  final repository = ref.watch(userStatsRepositoryProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.getXpHistory(userId);
});

// Gamification Provider
final gamificationProvider = NotifierProvider<GamificationNotifier, LevelState>(GamificationNotifier.new);

class GamificationNotifier extends Notifier<LevelState> {
  UserStats? _stats;
  String? _userId;

  @override
  LevelState build() {
    _userId = ref.watch(userIdProvider);
    
    // Watch the stats stream
    ref.listen(userStatsStreamProvider, (previous, next) {
      next.whenData((stats) {
        if (stats != null) {
          _stats = stats;
          _checkDailyReset();
          // Update state while preserving newly unlocked badges and level up status
          // as they might be waiting to be displayed by the UI
          state = _calculateState(
            stats, 
            newBadges: state.newlyUnlockedBadges, 
            leveledUp: state.leveledUp,
          );
        }
      });
    });

    // Initialize stats if needed
    if (_userId != null) {
      _initializeStats();
    }

    return LevelState(
      currentLevel: 1,
      title: 'Beginner',
      progress: 0.0,
      currentXp: 0,
      dailyStreak: 0,
      lastCheckInDate: '',
      unlockedBadgeCount: 0,
    );
  }

  Future<void> _initializeStats() async {
    if (_userId == null) return;
    
    final repository = ref.read(userStatsRepositoryProvider);
    await repository.initializeUserStats(_userId!);
  }

  void _checkDailyReset() {
    if (_stats == null) return;

    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Reset daily counters and check streak if it's a new day
    if (_stats!.lastActiveDate != today) {
      _stats!.todayFocusMinutes = 0;
      _stats!.todayTasksCompleted = 0;
      _stats!.lastActiveDate = today;

      // Reset streak if more than a day missed
      final yesterdayDate = now.subtract(const Duration(days: 1));
      final yesterday = '${yesterdayDate.year}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

      if (_stats!.lastCheckInDate != today && _stats!.lastCheckInDate != yesterday) {
        _stats!.dailyStreak = 0;
      }
    }
  }

  LevelState _calculateState(UserStats stats, {List<Badge> newBadges = const [], bool leveledUp = false}) {
    final level = GameConstants.getLevelForXp(stats.currentXp);
    final progress = GameConstants.getProgressToNextLevel(stats.currentXp);

    return LevelState(
      currentLevel: level.level,
      title: level.title,
      progress: progress.clamp(0.0, 1.0),
      currentXp: stats.currentXp,
      dailyStreak: stats.dailyStreak,
      lastCheckInDate: stats.lastCheckInDate,
      unlockedBadgeCount: stats.unlockedBadgeIds.length,
      newlyUnlockedBadges: newBadges,
      leveledUp: leveledUp,
    );
  }

  Future<Map<String, dynamic>> processAction({
    required String type,
    int? minutes,
    DateTime? sessionTime,
  }) async {
    if (_userId == null || _stats == null) return {'xpEarned': 0, 'badgeIds': []};

    final repository = ref.read(userStatsRepositoryProvider);
    
    // 1. Calculate Base XP
    int xpToAdd = GameConstants.xpSources[type] ?? 0;
    
    // 2. Update Stats based on action type
    if (type == 'focus_session') {
      _stats!.sessionsCompleted += 1;
      _stats!.totalFocusMinutes += (minutes ?? 0);
      _stats!.todayFocusMinutes += (minutes ?? 0);
      
      // Track longest session
      if (minutes != null && minutes > _stats!.longestSingleSession) {
        _stats!.longestSingleSession = minutes;
      }
    } else if (type == 'task_completed') {
      _stats!.tasksCompleted += 1;
      _stats!.todayTasksCompleted += 1;
    }
    
    // 3. Check for Badge Unlocks
    List<Badge> unlockedBadges = [];
    List<String> unlockedBadgeIds = [];
    for (var badge in BadgeRepository.allBadges) {
      if (!_stats!.unlockedBadgeIds.contains(badge.id)) {
        if (_evaluateUnlockCondition(badge, sessionTime: sessionTime)) {
          unlockedBadges.add(badge);
          unlockedBadgeIds.add(badge.id);
          _stats!.unlockedBadgeIds.add(badge.id);
          xpToAdd += badge.xp;
          
          // Record badge unlock
          await repository.recordBadgeUnlock(
            userId: _userId!,
            badgeId: badge.id,
            badgeTitle: badge.title,
          );
        }
      }
    }

    // 4. Check for Level Up
    final oldLevel = GameConstants.getLevelForXp(_stats!.currentXp).level;
    _stats!.currentXp += xpToAdd;
    final newLevel = GameConstants.getLevelForXp(_stats!.currentXp).level;
    bool leveledUp = newLevel > oldLevel;

    // 5. Save to Firestore
    await repository.saveUserStats(_stats!, _userId!);
    
    // 6. Record XP Transaction
    await repository.recordXpTransaction(
      userId: _userId!,
      xpAmount: xpToAdd,
      source: type,
      description: '${type.replaceAll('_', ' ')} - ${minutes ?? 0}m',
    );

    // 7. Update State
    state = _calculateState(_stats!, newBadges: unlockedBadges, leveledUp: leveledUp);
    
    return {
      'xpEarned': xpToAdd,
      'badgeIds': unlockedBadgeIds,
    };
  }

  void clearNewBadges() {
    if (_stats == null) return;
    state = _calculateState(_stats!, newBadges: [], leveledUp: false);
  }

  Future<void> checkIn() async {
    if (_userId == null || _stats == null) return;

    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    if (_stats!.lastCheckInDate == today) return; // Already checked in today

    final yesterdayDate = now.subtract(const Duration(days: 1));
    final yesterday = '${yesterdayDate.year}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

    // Update Streak
    if (_stats!.lastCheckInDate == yesterday) {
      _stats!.dailyStreak += 1;
    } else {
      _stats!.dailyStreak = 1;
    }

    _stats!.lastCheckInDate = today;
    _stats!.lastActiveDate = today;

    // Award Daily Login XP
    await processAction(type: 'daily_login');
  }

  bool _evaluateUnlockCondition(Badge badge, {DateTime? sessionTime}) {
    if (_stats == null) return false;

    switch (badge.unlockType) {
      case 'session_count':
        return _stats!.sessionsCompleted >= badge.unlockValue;
        
      case 'daily_streak':
        return _stats!.dailyStreak >= badge.unlockValue;
        
      case 'single_session_minutes':
        return _stats!.longestSingleSession >= badge.unlockValue;
        
      case 'daily_focus_minutes':
        return _stats!.todayFocusMinutes >= badge.unlockValue;
        
      case 'daily_tasks':
        return _stats!.todayTasksCompleted >= badge.unlockValue;
        
      case 'task_completed':
        return _stats!.tasksCompleted >= badge.unlockValue;
        
      case 'time_of_day':
        if (sessionTime == null) return false;
        final hour = sessionTime.hour;
        
        if (badge.timeCondition == 'morning') {
          // 5 AM - 11 AM
          return hour >= 5 && hour < 11;
        } else if (badge.timeCondition == 'night') {
          // 9 PM - 2 AM
          return hour >= 21 || hour < 2;
        }
        return false;
        
      case 'comeback':
        // Check if user returned after 7+ days
        if (_stats!.lastActiveDate.isEmpty) return false;
        
        final lastActive = DateTime.tryParse(_stats!.lastActiveDate);
        if (lastActive == null) return false;
        
        final daysSinceActive = DateTime.now().difference(lastActive).inDays;
        return daysSinceActive >= badge.unlockValue;
        
      default:
        return false;
    }
  }
}
