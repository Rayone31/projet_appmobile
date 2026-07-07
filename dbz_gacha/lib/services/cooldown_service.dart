import 'package:shared_preferences/shared_preferences.dart';

class CooldownService {
  static const String _key = 'last_invocation_time';
  static const Duration cooldownDuration = Duration(minutes: 5);

  Future<void> saveInvocationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
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