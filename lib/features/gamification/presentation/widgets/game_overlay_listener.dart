import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:gap/gap.dart';
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
      debugPrint("Gamification listener fired: badges=${next.newlyUnlockedBadges.length}, leveledUp=${next.leveledUp}");
      
      if (next.newlyUnlockedBadges.isNotEmpty) {
        debugPrint("Showing Badge Popup for: ${next.newlyUnlockedBadges.map((b) => b.title)}");
        // Show Badge Popup and then Level Up Popup if needed
        _showBadgePopup(context, next.newlyUnlockedBadges).then((_) {
          _confettiController.play();
          
          if (next.leveledUp && mounted) {
            debugPrint("Showing Level Up Popup after badges");
            _showLevelUpPopup(context, next.currentLevel, next.title).then((_) {
              _confettiController.play();
            });
          }
        });
      } else if (next.leveledUp) {
        debugPrint("Showing Level Up Popup only");
        // Show Level Up Popup only
        _showLevelUpPopup(context, next.currentLevel, next.title).then((_) {
          _confettiController.play();
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
    final bool isMultiple = badges.length > 1;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMultiple)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              const Gap(24),
              Text(
                isMultiple ? "Badges Unlocked!" : "Badge Unlocked!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              Text(
                isMultiple 
                  ? "You've been incredibly productive! You earned:"
                  : "You've earned the '${badges.first.title}' badge for your dedication.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (isMultiple) ...[
                const Gap(24),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: badges.map((badge) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(badge.icon, size: 32, color: Colors.amber),
                      ),
                      const Gap(8),
                      Text(
                        badge.title,
                        style: const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.amber,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )).toList(),
                ),
              ],
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Awesome!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showLevelUpPopup(BuildContext context, int level, String title) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch_rounded, size: 64, color: Colors.blueAccent),
              ),
              const Gap(24),
              const Text(
                "Level Up!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              Column(
                children: [
                  Text(
                    "You reached Level $level",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blueAccent, 
                        fontWeight: FontWeight.w900, 
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Let's Go!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
