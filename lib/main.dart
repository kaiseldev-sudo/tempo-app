import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/ledger/domain/time_entry.dart';
import 'features/gamification/data/user_stats.dart';
import 'features/gamification/presentation/providers/gamification_provider.dart';
import 'features/gamification/presentation/widgets/game_overlay_listener.dart';
import 'main_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Sign in anonymously if not already signed in
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
  } catch (e) {
      debugPrint("Firebase initialization failed: $e");
      // Continue anyway for now
  }
  await Hive.initFlutter();
  Hive.registerAdapter(TimeEntryAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  try {
    await Hive.openBox<TimeEntry>('time_entries');
    await Hive.openBox<UserStats>('user_stats');
  } catch (e) {
    // Fallback if box is corrupted during dev
    await Hive.deleteBoxFromDisk('time_entries');
    await Hive.deleteBoxFromDisk('user_stats');
    await Hive.openBox<TimeEntry>('time_entries');
    await Hive.openBox<UserStats>('user_stats');
  }

  runApp(const ProviderScope(child: TempoApp()));
}

class TempoApp extends StatelessWidget {
  const TempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempo',
      theme: AppTheme.lightTheme,
      home: const GameOverlayListener(child: MainScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
