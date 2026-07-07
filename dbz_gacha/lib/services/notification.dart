import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../routes/router.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        router.go('/invocation');
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleInvocationReadyNotification(Duration delay) async {
    const androidDetails = AndroidNotificationDetails(
      'invocation_channel',
      'Invocation',
      channelDescription: 'Notifie quand une invocation est disponible',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.cancel(id: 0);

    await _plugin.zonedSchedule(
      id: 0,
      title: 'DBZ Gacha',
      body: 'Invocation disponible !!!',
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelScheduledNotification() async {
    await _plugin.cancel(id: 0);
  }

  Future<void> showTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test',
        channelDescription: 'Notification de test',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 1,
      title: 'DBZ Gacha',
      body: 'Notification test OK',
      notificationDetails: details,
    );
  }
}