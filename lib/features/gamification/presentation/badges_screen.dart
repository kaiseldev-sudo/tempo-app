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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // Group badges by category
    final streakBadges = BadgeRepository.getBadgesByCategory('streak');
    final focusBadges = BadgeRepository.getBadgesByCategory('focus');
    final milestoneBadges = BadgeRepository.getBadgesByCategory('milestone');
    final specialBadges = BadgeRepository.getBadgesByCategory('special');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20), 
                onPressed: () => Navigator.pop(context)
              ) 
            : null,
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
              context,
              '🔥 Consistency & Streaks',
              streakBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Focus & Productivity
            _buildCategorySection(
              context,
              '🎯 Focus & Productivity',
              focusBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Progress & Milestones
            _buildCategorySection(
              context,
              '🚀 Progress & Milestones',
              milestoneBadges,
              unlockedBadgeIds,
            ),

            const Gap(24),

            // Special
            _buildCategorySection(
              context,
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
    BuildContext context,
    String title,
    List<Badge> badges,
    List<String> unlockedIds,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
              color: textColor,
            ),
          ),
          const Gap(20),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.6,
            children: badges.map<Widget>((badge) {
              final isUnlocked = unlockedIds.contains(badge.id);
              return _buildBadgeCard(context, badge, isUnlocked);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, Badge badge, bool isUnlocked) {
    final Color badgeColor = isUnlocked ? badge.color : Colors.grey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? (isDark ? badgeColor.withValues(alpha: 0.1) : badgeColor.withValues(alpha: 0.05))
            : (isDark ? Colors.grey[800] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked 
              ? badgeColor.withValues(alpha: 0.2) 
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? badgeColor.withValues(alpha: 0.1) 
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked 
                    ? badgeColor.withValues(alpha: 0.2) 
                    : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                width: 1,
              ),
            ),
            child: Icon(
              badge.icon,
              color: isUnlocked 
                  ? badgeColor 
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
          ),
          
          const Gap(10),
          
          // Title
          Text(
            badge.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isUnlocked 
                  ? (isDark ? Colors.white : Colors.black) 
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              height: 1.1,
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
              fontSize: 9,
              color: isUnlocked 
                  ? (isDark ? Colors.grey[400] : Colors.grey[700]) 
                  : Colors.grey[500],
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Gap(8),
          
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? badgeColor.withValues(alpha: 0.1) 
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUnlocked ? badgeColor.withValues(alpha: 0.2) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  size: 10,
                  color: isUnlocked ? badgeColor : Colors.grey[600],
                ),
                const Gap(4),
                Text(
                  '+${badge.xp} XP',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? badgeColor : Colors.grey[600],
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
