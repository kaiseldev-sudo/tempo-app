import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../domain/badge_model.dart';
import '../providers/gamification_provider.dart';
import '../badges_screen.dart';

class GamificationStatsSummary extends ConsumerWidget {
  const GamificationStatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gamificationProvider);
    final box = ref.read(userStatsBoxProvider);
    // Directly fetching unlockedIds from box since LevelState might contain count only based on previous edit.
    // Wait, in provider I stored counts. I should update LevelState to just store the IDs list for consistency?
    // Actually box access here is fine, OR update LevelState.
    // Let's use box to get IDs for navigation.
    
    // Better: Update LevelState to carry unlockedIds. But for now I'll just use box.
    // Wait, ref.read(userValues) is cleaner.
    
    List<String> unlockedIds = [];
    if (box.isNotEmpty) {
      unlockedIds = box.values.first.unlockedBadgeIds;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Streak
              Column(
                children: [
                   const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                   const Gap(4),
                   Text(
                     "${gameState.dailyStreak} Day Streak",
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                   ),
                ],
              ),
              
              // Divider
              Container(width: 1, height: 40, color: Colors.grey[300]),
              
              // Badges
              GestureDetector(
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BadgesScreen(
                        unlockedCount: gameState.unlockedBadgeCount,
                        totalCount: BadgeRepository.allBadges.length,
                        currentXp: gameState.currentXp,
                        currentLevel: gameState.currentLevel,
                        levelTitle: gameState.title,
                        unlockedIds: unlockedIds,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                    const Gap(4),
                    const Text(
                      "Badges",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "See all",
                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    )
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          // XP Progress Bar (Mini)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: gameState.progress,
              backgroundColor: Colors.grey[200],
              color: Colors.black,
              minHeight: 6,
            ),
          ),
          const Gap(4),
          Text(
            "Lvl ${gameState.currentLevel}: ${gameState.title}",
             style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
