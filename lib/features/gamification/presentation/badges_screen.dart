import 'package:flutter/material.dart' hide Badge;
import '../domain/badge_model.dart';
import '../domain/game_constants.dart';

class BadgesScreen extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;
  final int currentXp;
  final int currentLevel;
  final String levelTitle;
  final List<String> unlockedIds;
  
  const BadgesScreen({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
    required this.currentXp,
    required this.currentLevel,
    required this.levelTitle,
    required this.unlockedIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Level Hexagon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Icon(Icons.hexagon, size: 120, color: Colors.amber[100]),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$currentLevel",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        levelTitle,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "$currentXp XP Total",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            
            // Badges Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Badges", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("$unlockedCount / $totalCount", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: BadgeRepository.allBadges.length,
              itemBuilder: (context, index) {
                final badge = BadgeRepository.allBadges[index];
                final isUnlocked = unlockedIds.contains(badge.id);
                
                return _BadgeItem(badge: badge, isUnlocked: isUnlocked);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;

  const _BadgeItem({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.amber[50] : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? Colors.amber : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Icon(
            badge.icon,
            color: isUnlocked ? Colors.amber[800] : Colors.grey[400],
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isUnlocked ? Colors.black : Colors.grey,
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
