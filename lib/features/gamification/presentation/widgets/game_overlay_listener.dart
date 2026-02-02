import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:gap/gap.dart';
import '../providers/gamification_provider.dart';

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
      if (next.newlyUnlockedBadges.isNotEmpty) {
        // Show Badge Popup
        _showBadgePopup(context, next.newlyUnlockedBadges.first.title);
        _confettiController.play();
      } else if (next.leveledUp) {
        // Show Level Up Popup
        _showLevelUpPopup(context, next.currentLevel, next.title);
        _confettiController.play();
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

  void _showBadgePopup(BuildContext context, String badgeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.emoji_events, size: 48, color: Colors.amber),
            Gap(8),
            Text("Badge Unlocked!", textAlign: TextAlign.center),
          ],
        ),
        content: Text("You've earned the '$badgeName' badge.", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }
  
  void _showLevelUpPopup(BuildContext context, int level, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.rocket_launch, size: 48, color: Colors.blueAccent),
            Gap(8),
            Text("Level Up!", textAlign: TextAlign.center),
          ],
        ),
        content: Text("You are now Level $level: $title", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Let's Go!"),
          ),
        ],
      ),
    );
  }
}
