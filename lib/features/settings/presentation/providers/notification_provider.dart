import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadNotificationSettings();
    return true;
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notificationsEnabled') ?? true;
  }

  Future<void> toggleNotifications() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', state);
    
    // TODO: Implement actual notification permission handling
    // if (state) {
    //   // Request notification permissions
    // } else {
    //   // Disable notifications
    // }
  }

  Future<void> setNotifications(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, bool>(() {
  return NotificationNotifier();
});
