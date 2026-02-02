import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/gamification_provider.dart';
import '../badges_screen.dart';
import '../xp_history_screen.dart';

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
          // Level & Progress Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Soft minimalist orange
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFEDD5)), // Subtle orange-tinted border
              // Removed boxShadow (glow effect) as requested
            ),
            child: Row(
              children: [
                // Level Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${gameState.currentLevel}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      gameState.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // XP Progress Circle (Added a subtle animation here too)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: gameState.progress),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey[100],
                            color: Colors.black,
                            strokeWidth: 5,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Gap(12),
          // Stats Grid
          Row(
            children: [
              // Streak
              Expanded(
                child: _buildStatContainer(
                  icon: Icons.local_fire_department_rounded,
                  value: '${gameState.dailyStreak}',
                  label: 'Streak',
                  color: Colors.orange,
                  onTap: () {},
                  index: 0,
                ),
              ),
              const Gap(12),
              // Badges
              Expanded(
                child: _buildStatContainer(
                  icon: Icons.emoji_events_rounded,
                  value: '${unlockedIds.length}',
                  label: 'Badges',
                  color: Colors.amber,
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
                  index: 1,
                ),
              ),
              const Gap(12),
              // XP
              Expanded(
                child: _buildStatContainer(
                  icon: Icons.stars_rounded,
                  value: '${gameState.currentXp}',
                  label: 'Total XP',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const XPHistoryScreen(),
                      ),
                    );
                  },
                  index: 2,
                ),
              ),
            ],
          ),
          const Gap(20),
          // Check In Button (Conditional)
          if (gameState.lastCheckInDate != today)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(gamificationProvider.notifier).checkIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20),
                    Gap(10),
                    Text(
                      'Check In Today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: Colors.green[600]),
                  const Gap(10),
                  Text(
                    'Daily Check-in Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatContainer({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 200)),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(icon, color: color, size: 26),
                );
              },
            ),
            const Gap(8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

