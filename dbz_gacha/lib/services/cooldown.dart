import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';

class CooldownService {
  static const String _key = 'last_invocation_time';
  static const Duration cooldownDuration = Duration(minutes: 5); // la valeur peut étre changer pour des test (seconds: 10) actuellement il est réglé sur 5 minute

  Future<void> saveInvocationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);

    debugPrint('Programmation de la notification dans $cooldownDuration');
    await NotificationService().scheduleInvocationReadyNotification(
      cooldownDuration,
    );
    debugPrint('Notification programmée avec succès');
  }

  Future<Duration> getRemainingCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt(_key);

    if (lastTime == null) return Duration.zero;

    final lastInvocation = DateTime.fromMillisecondsSinceEpoch(lastTime);
    final elapsed = DateTime.now().difference(lastInvocation);
    final remaining = cooldownDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}