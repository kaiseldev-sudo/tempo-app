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
          state = _calculateState(stats);
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
      unlockedBadgeCount: 0,
    );
  }

  Future<void> _initializeStats() async {
    if (_userId == null) return;
    
    final repository = ref.read(userStatsRepositoryProvider);
    await repository.initializeUserStats(_userId!);
  }

  LevelState _calculateState(UserStats stats, {List<Badge> newBadges = const [], bool leveledUp = false}) {
    final level = GameConstants.getLevelForXp(stats.currentXp);
    final nextLevel = GameConstants.getLevelForXp(stats.currentXp + 1);
    final progress = (stats.currentXp - level.xpRequired) / (nextLevel.xpRequired - level.xpRequired);

    return LevelState(
      currentLevel: level.level,
      title: level.title,
      progress: progress.clamp(0.0, 1.0),
      currentXp: stats.currentXp,
      dailyStreak: stats.dailyStreak,
      unlockedBadgeCount: stats.unlockedBadgeIds.length,
      newlyUnlockedBadges: newBadges,
      leveledUp: leveledUp,
    );
  }

  Future<void> processAction({required String type, int? minutes}) async {
    if (_userId == null || _stats == null) return;

    final repository = ref.read(userStatsRepositoryProvider);
    
    // 1. Calculate Base XP
    int xpToAdd = GameConstants.xpSources[type] ?? 0;
    
    // 2. Update Stats based on action type
    if (type == 'focus_session') {
      _stats!.sessionsCompleted += 1;
      _stats!.totalFocusMinutes += (minutes ?? 0);
    } else if (type == 'task_completed') {
      _stats!.tasksCompleted += 1;
    }
    
    // 3. Check for Badge Unlocks
    List<Badge> unlockedBadges = [];
    for (var badge in BadgeRepository.allBadges) {
      if (!_stats!.unlockedBadgeIds.contains(badge.id)) {
        if (_evaluateUnlockCondition(badge)) {
          unlockedBadges.add(badge);
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
  }

  bool _evaluateUnlockCondition(Badge badge) {
    if (_stats == null) return false;

    switch (badge.unlockType) {
      case 'session_count':
        return _stats!.sessionsCompleted >= badge.unlockValue;
      case 'total_focus_hours':
        return _stats!.totalFocusMinutes >= (badge.unlockValue * 60);
      case 'daily_streak':
        return _stats!.dailyStreak >= badge.unlockValue;
      case 'single_session_minutes':
        return _stats!.totalFocusMinutes >= badge.unlockValue; // Simplified for MVP
      case 'task_completed':
        return _stats!.tasksCompleted >= badge.unlockValue;
      default:
        return false;
    }
  }
}
