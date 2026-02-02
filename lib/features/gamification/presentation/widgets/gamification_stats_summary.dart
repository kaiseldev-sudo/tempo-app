import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/gamification_provider.dart';
import '../badges_screen.dart';
import '../../domain/badge_model.dart';

class GamificationStatsSummary extends ConsumerWidget {
  const GamificationStatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gamificationProvider);
    final userStatsAsync = ref.watch(userStatsStreamProvider);
    
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    List<String> unlockedIds = [];
    userStatsAsync.whenData((stats) {
      if (stats != null) {
        unlockedIds = stats.unlockedBadgeIds;
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // Level Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${gameState.currentLevel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    gameState.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // XP Progress Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: gameState.progress,
                      backgroundColor: Colors.grey[200],
                      color: Colors.amber,
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '${(gameState.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak
              _buildCompactStat(
                icon: Icons.local_fire_department,
                value: '${gameState.dailyStreak}',
                label: 'Streak',
                color: Colors.orange,
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
                        unlockedBadgeIds: unlockedIds,
                      ),
                    ),
                  );
                },
                child: _buildCompactStat(
                  icon: Icons.emoji_events,
                  value: '${unlockedIds.length}',
                  label: 'Badges',
                  color: Colors.amber,
                ),
              ),
              
              // Divider
              Container(width: 1, height: 40, color: Colors.grey[300]),
              
              // Total XP
              _buildCompactStat(
                icon: Icons.stars,
                value: '${gameState.currentXp}',
                label: 'Total XP',
                color: Colors.purple,
              ),
            ],
          ),
          const Gap(24),
          // Check In Button (Conditional)
          if (gameState.lastCheckInDate != today)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(gamificationProvider.notifier).checkIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    Gap(8),
                    Text(
                      'Check In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green[600]),
                  const Gap(8),
                  Text(
                    'Checked In for Today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
