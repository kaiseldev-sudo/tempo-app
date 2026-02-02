import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon; // Simplified for MVP (using Material Icons)
  final String category;
  final int xp;
  final String unlockType;
  final int unlockValue;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.xp,
    required this.unlockType,
    required this.unlockValue,
  });
}

class BadgeRepository {
  static const List<Badge> allBadges = [
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
      id: "deep_focus",
      title: "Deep Focus",
      description: "Complete 60 minutes in one session",
      icon: Icons.psychology,
      category: "focus",
      xp: 100,
      unlockType: "single_session_minutes",
      unlockValue: 60,
    ),
    Badge(
      id: "seven_day_streak",
      title: "7 Day Streak",
      description: "Stay consistent for 7 days",
      icon: Icons.local_fire_department,
      category: "streak",
      xp: 150,
      unlockType: "daily_streak",
      unlockValue: 7,
    ),
    Badge(
      id: "task_crusher",
      title: "Task Crusher",
      description: "Complete 50 tasks",
      icon: Icons.check_circle_outline,
      category: "milestone",
      xp: 200,
      unlockType: "task_completed",
      unlockValue: 50,
    ),
  ];
}
