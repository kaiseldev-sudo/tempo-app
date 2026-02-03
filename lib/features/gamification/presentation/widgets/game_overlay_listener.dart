import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/gamification_provider.dart';
import '../../domain/badge_model.dart';

class GameOverlayListener extends ConsumerStatefulWidget {
  final Widget child;
  const GameOverlayListener({super.key, required this.child});

  @override
  ConsumerState<GameOverlayListener> createState() => _GameOverlayListenerState();
}

class _GameOverlayListenerState extends ConsumerState<GameOverlayListener> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to gamification state changes
    ref.listen(gamificationProvider, (previous, next) {
      final hadBadges = previous?.newlyUnlockedBadges.isNotEmpty ?? false;
      final hasBadges = next.newlyUnlockedBadges.isNotEmpty;
      final hadLevelUp = previous?.leveledUp ?? false;
      final hasLevelUp = next.leveledUp;

      // Only trigger if we transitioned from NO badges to HAVING badges
      // or if the set of badges actually changed
      if (hasBadges && !hadBadges) {
        debugPrint("🏆 TRIGGER: Showing Badge Popup for: ${next.newlyUnlockedBadges.map((b) => b.title)}");
        
        _showBadgePopup(context, next.newlyUnlockedBadges).then((_) {
          if (!context.mounted) return;
          _confettiController.play();
          
          if (next.leveledUp) {
            _showLevelUpPopup(context, next.currentLevel, next.title).then((_) {
              if (context.mounted) {
                _confettiController.play();
                ref.read(gamificationProvider.notifier).clearNewBadges();
              }
            });
          } else {
            // Clear badges if no level up is pending
            ref.read(gamificationProvider.notifier).clearNewBadges();
          }
        });
      } else if (hasLevelUp && !hadLevelUp && !hasBadges) {
        // Only trigger level up solo if no badges are being shown
        debugPrint("🚀 TRIGGER: Showing Level Up Popup only");
        _showLevelUpPopup(context, next.currentLevel, next.title).then((_) {
          if (mounted) {
            _confettiController.play();
            ref.read(gamificationProvider.notifier).clearNewBadges();
          }
        });
      }
    });

    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }

  Future<void> _showBadgePopup(BuildContext context, List<Badge> badges) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badges.length > 1 ? "New Achievements\nUnlocked" : "New Achievement\nUnlocked",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    badges.length > 1 
                        ? "You've been incredibly productive today. Keep up the momentum!"
                        : badges.first.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const Gap(40),
                  
                  // Decorative curved lines (simplified)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDecorativeLine(-0.5),
                      const Gap(8),
                      _buildDecorativeLine(-0.2),
                      const Gap(12),
                      _buildDecorativeLine(0.2),
                      const Gap(8),
                      _buildDecorativeLine(0.5),
                    ],
                  ),
                  const Gap(24),

                  // Badges Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: badges.map((badge) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Icon(badge.icon, size: 28, color: Colors.black),
                            ),
                            const Gap(8),
                            Text(
                              badge.title,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const Gap(40),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "GOT IT",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Close Button
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeLine(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 2,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
  
  Future<void> _showLevelUpPopup(BuildContext context, int level, String title) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You've leveled up!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    "You've reached Level $level. Your dedication is truly inspiring.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const Gap(40),
                  
                  // Decorative curved lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDecorativeLine(-0.5),
                      const Gap(8),
                      _buildDecorativeLine(-0.2),
                      const Gap(12),
                      _buildDecorativeLine(0.2),
                      const Gap(8),
                      _buildDecorativeLine(0.5),
                    ],
                  ),
                  const Gap(24),

                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.rocket_launch_rounded, size: 40, color: Colors.black),
                        const Gap(8),
                        Text(
                          "LEVEL $level",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(40),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "AWESOME",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Close Button
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
