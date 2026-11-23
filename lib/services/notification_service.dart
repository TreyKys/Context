import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import '../models/word_list.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _payloadController =
      StreamController<String>.broadcast();

  /// Emits when the user taps a notification while the app is already running.
  Stream<String> get payloadStream => _payloadController.stream;

  String? initialPayload;
  bool _initialPayloadConsumed = false;

  /// Returns [initialPayload] at most once so tab rebuilds do not re-run the
  /// same notification lookup and burn extra searches.
  String? consumeInitialPayload([String? fallbackPayload]) {
    if (_initialPayloadConsumed) return null;
    final payload = initialPayload ?? fallbackPayload;
    if (payload == null || payload.trim().isEmpty) return null;
    _initialPayloadConsumed = true;
    initialPayload = null;
    return payload.trim();
  }

  Future<void> init() async {
    // Initialize Timezone
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // Fallback
      tz.setLocalLocation(tz.getLocation('America/New_York'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Get any notification that launched the app
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      initialPayload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      _initialPayloadConsumed = false;
    }

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.trim().isNotEmpty) {
          _payloadController.add(payload.trim());
        }
      },
    );
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyNotifications({bool force = false}) async {
    // Only reschedule if forced or not already scheduled (prevents duplicates on every launch)
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getString('notifications_last_scheduled');
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (!force && lastScheduled == today) return;

    await _flutterLocalNotificationsPlugin.cancelAll();
    await prefs.setString('notifications_last_scheduled', today);

    final Random random = Random();
    final List<String> shuffledWords = List.from(trendingWords)
      ..shuffle(random);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_word_channel',
          'Word of the Day',
          channelDescription: 'Daily trending word to Vibe Translate',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        );
    const NotificationDetails platformChannelDetails = NotificationDetails(
      android: androidDetails,
    );

    // Schedule the next 14 days of notifications at 10:00 AM
    for (int i = 0; i < 14; i++) {
      if (i >= shuffledWords.length) break;

      final word = shuffledWords[i];

      tz.TZDateTime scheduledDate = _nextInstanceOfTenAM(i + 1);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        i, // unique ID
        '🔥 Word of the Day: $word',
        'Tap to see the Vibe Translation!',
        scheduledDate,
        platformChannelDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: word,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTenAM(int daysToAdd) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate.add(Duration(days: daysToAdd - 1));
  }
}
