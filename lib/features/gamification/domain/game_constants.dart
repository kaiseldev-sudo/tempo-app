import 'package:flutter/material.dart';

class Level {
  final int level;
  final String title;
  final int xpRequired;

  const Level({
    required this.level,
    required this.title,
    required this.xpRequired,
  });
}

class GameConstants {
  static const List<Level> levels = [
    Level(level: 1, title: "Beginner", xpRequired: 0),
    Level(level: 2, title: "Getting Started", xpRequired: 100),
    Level(level: 3, title: "Focused", xpRequired: 250),
    Level(level: 4, title: "Consistent", xpRequired: 500),
    Level(level: 5, title: "Productive", xpRequired: 900),
    Level(level: 6, title: "Time Master", xpRequired: 1400),
    Level(level: 7, title: "Elite Performer", xpRequired: 2000),
  ];

  static const Map<String, int> xpSources = {
    "focus_session": 20,
    "task_completed": 10,
    "daily_login": 5,
  };

  static Level getLevelForXp(int currentXp) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (currentXp >= levels[i].xpRequired) {
        return levels[i];
      }
    }
    return levels[0];
  }
  
  static double getProgressToNextLevel(int currentXp) {
    Level currentLevel = getLevelForXp(currentXp);
    Level? nextLevel;
    
    // Find next level
    for (var l in levels) {
      if (l.level == currentLevel.level + 1) {
        nextLevel = l;
        break;
      }
    }
    
    if (nextLevel == null) return 1.0; // Max level
    
    int xpInCurrentLevel = currentXp - currentLevel.xpRequired;
    int xpNeededForNext = nextLevel.xpRequired - currentLevel.xpRequired;
    
    return xpInCurrentLevel / xpNeededForNext;
  }
}
