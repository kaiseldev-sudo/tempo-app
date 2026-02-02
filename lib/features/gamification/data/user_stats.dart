import 'package:hive_flutter/hive_flutter.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 1) // TypeId 1 for UserStats
class UserStats extends HiveObject {
  @HiveField(0)
  int currentXp;

  @HiveField(1)
  int totalFocusMinutes;

  @HiveField(2)
  int tasksCompleted;

  @HiveField(3)
  int sessionsCompleted;

  @HiveField(4)
  int dailyStreak;

  @HiveField(5)
  List<String> unlockedBadgeIds;

  @HiveField(6)
  int lastLoginMs;

  UserStats({
    this.currentXp = 0,
    this.totalFocusMinutes = 0,
    this.tasksCompleted = 0,
    this.sessionsCompleted = 0,
    this.dailyStreak = 0,
    this.unlockedBadgeIds = const [],
    this.lastLoginMs = 0,
  });
}
