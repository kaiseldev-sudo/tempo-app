import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../domain/badge_model.dart';
import '../presentation/providers/gamification_provider.dart';

class BadgesScreen extends ConsumerWidget {
  final List<String> unlockedBadgeIds;

  const BadgesScreen({
    super.key,
    required this.unlockedBadgeIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gamificationProvider);

    // Group badges by category
    final streakBadges = BadgeRepository.getBadgesByCategory('streak');
    final focusBadges = BadgeRepository.getBadgesByCategory('focus');
    final milestoneBadges = BadgeRepository.getBadgesByCategory('milestone');
    final specialBadges = BadgeRepository.getBadgesByCategory('special');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF333333)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '${unlockedBadgeIds.length}',
                    'Unlocked',
                    Icons.emoji_events,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                  ),
                  _buildStatItem(
                    '${BadgeRepository.allBadges.length - unlockedBadgeIds.length}',
                    'Locked',
                    Icons.lock_outline,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                  ),
                  _buildStatItem(
                    '${gameState.currentXp}',
                    'Total XP',
                    Icons.stars,
                  ),
                ],
              ),
            ),

            const Gap(32),

            // Consistency & Streaks
            _buildCategorySection(
              '🔥 Consistency & Streaks',
              streakBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Focus & Productivity
            _buildCategorySection(
              '🎯 Focus & Productivity',
              focusBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Progress & Milestones
            _buildCategorySection(
              '🚀 Progress & Milestones',
              milestoneBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Special
            _buildCategorySection(
              '✨ Special',
              specialBadges,
              unlockedBadgeIds,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const Gap(8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Badge> badges,
    List<String> unlockedIds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map<Widget>((badge) {
            final isUnlocked = unlockedIds.contains(badge.id);
            return _buildBadgeCard(badge, isUnlocked);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isUnlocked) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.amber : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              color: isUnlocked ? Colors.white : Colors.grey[600],
              size: 32,
            ),
          ),
          
          const Gap(12),
          
          // Title
          Text(
            badge.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked ? Colors.black : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Gap(4),
          
          // Description
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Gap(8),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  size: 12,
                  color: isUnlocked ? Colors.white : Colors.grey[600],
                ),
                const Gap(4),
                Text(
                  '+${badge.xp} XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
