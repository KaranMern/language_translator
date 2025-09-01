import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class LocalNotification {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Future localInit() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationClick(details.payload);
      },
    );

    // Check if the app was launched from a notification (when terminated)
    final NotificationAppLaunchDetails? details =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationClick(details!.notificationResponse?.payload);
    }

    // Request notification permission for Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  //Instant Notification
  static Future showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails androidNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      androidNotificationDetails,
      payload: payload,
    );
  }

  //scheduled Notification
  static Future scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate,
    int id,
  ) async {
    const NotificationDetails androidNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      androidNotificationDetails,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  //Repeated Notification
  static Future<void> scheduleRepeatingNotification(
    String title,
    String body,
    DateTime scheduledDate,
    DateTimeComponents dateTimeComponent,
    int id,
  ) async {
    NotificationDetails androidNotificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        "channel",
        'Recurring Notifications',
        channelDescription: 'Channel for repeating notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      androidNotificationDetails,
      matchDateTimeComponents:
          dateTimeComponent, // Triggers on the selected interval
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: id.toString(),
    );
  }

  //Periodic Notification
  static Future<void> schedulePeriodicNotification() async {
    int randomId = Random().nextInt(1000);
    _flutterLocalNotificationsPlugin.periodicallyShow(
      randomId,
      "Repetitive $randomId",
      "Testing Zoned Notification $randomId",
      RepeatInterval.everyMinute,
      NotificationDetails(
        android: AndroidNotificationDetails(
          "channel",
          'Recurring Notifications',
          channelDescription: 'Channel for repeating notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  //onClick Function
  static void _handleNotificationClick(payload) {
    navigatorsKey.currentState?.pushReplacementNamed(
      'Profile',
      arguments: payload,
    );
  }

  //Cancel Notification
  static Future<void> cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  //Cancel Notification By Id
  static Future<void> cancelNotificationById(id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
