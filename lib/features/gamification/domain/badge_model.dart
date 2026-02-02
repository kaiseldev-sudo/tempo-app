import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final int xp;
  final String unlockType;
  final int unlockValue;
  final String? timeCondition; // 'morning', 'night', or null

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.xp,
    required this.unlockType,
    required this.unlockValue,
    this.timeCondition,
  });
}

class BadgeRepository {
  static const List<Badge> allBadges = [
    // CONSISTENCY & STREAKS (3)
    Badge(
      id: "first_step",
      title: "First Step",
      description: "Complete your first focus session",
      icon: Icons.directions_walk,
      category: "streak",
      xp: 50,
      unlockType: "session_count",
      unlockValue: 1,
    ),
    Badge(
      id: "three_day_streak",
      title: "3-Day Streak",
      description: "Stay consistent for 3 days in a row",
      icon: Icons.local_fire_department,
      category: "streak",
      xp: 100,
      unlockType: "daily_streak",
      unlockValue: 3,
    ),
    Badge(
      id: "seven_day_streak",
      title: "7-Day Streak",
      description: "Maintain a 7-day streak",
      icon: Icons.whatshot,
      category: "streak",
      xp: 200,
      unlockType: "daily_streak",
      unlockValue: 7,
    ),

    // FOCUS & PRODUCTIVITY (3)
    Badge(
      id: "deep_focus",
      title: "Deep Focus",
      description: "Complete 60 minutes uninterrupted",
      icon: Icons.psychology,
      category: "focus",
      xp: 150,
      unlockType: "single_session_minutes",
      unlockValue: 60,
    ),
    Badge(
      id: "flow_state",
      title: "Flow State",
      description: "Log 2 hours of focus in one day",
      icon: Icons.water_drop,
      category: "focus",
      xp: 200,
      unlockType: "daily_focus_minutes",
      unlockValue: 120,
    ),
    Badge(
      id: "task_crusher",
      title: "Task Crusher",
      description: "Complete 10 tasks in one day",
      icon: Icons.bolt,
      category: "focus",
      xp: 150,
      unlockType: "daily_tasks",
      unlockValue: 10,
    ),

    // PROGRESS & MILESTONES (3)
    Badge(
      id: "getting_started",
      title: "Getting Started",
      description: "Complete 5 tasks total",
      icon: Icons.rocket_launch,
      category: "milestone",
      xp: 75,
      unlockType: "task_completed",
      unlockValue: 5,
    ),
    Badge(
      id: "momentum",
      title: "Momentum",
      description: "Complete 25 tasks total",
      icon: Icons.trending_up,
      category: "milestone",
      xp: 150,
      unlockType: "task_completed",
      unlockValue: 25,
    ),
    Badge(
      id: "on_fire",
      title: "On Fire",
      description: "Complete 100 tasks total",
      icon: Icons.whatshot,
      category: "milestone",
      xp: 300,
      unlockType: "task_completed",
      unlockValue: 100,
    ),

    // SPECIAL (3)
    Badge(
      id: "early_bird",
      title: "Early Bird",
      description: "Complete a morning session (5 AM - 11 AM)",
      icon: Icons.wb_sunny,
      category: "special",
      xp: 100,
      unlockType: "time_of_day",
      unlockValue: 1,
      timeCondition: 'morning',
    ),
    Badge(
      id: "night_owl",
      title: "Night Owl",
      description: "Complete a late session (9 PM - 2 AM)",
      icon: Icons.nightlight_round,
      category: "special",
      xp: 100,
      unlockType: "time_of_day",
      unlockValue: 1,
      timeCondition: 'night',
    ),
    Badge(
      id: "comeback_kid",
      title: "Comeback Kid",
      description: "Return after 7+ days of inactivity",
      icon: Icons.refresh,
      category: "special",
      xp: 150,
      unlockType: "comeback",
      unlockValue: 7,
    ),
  ];

  static Badge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Badge> getBadgesByCategory(String category) {
    return allBadges.where((badge) => badge.category == category).toList();
  }
}
