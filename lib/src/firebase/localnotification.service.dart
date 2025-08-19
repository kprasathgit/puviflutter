// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class LocalNotificationService {
//   // Singleton pattern
//   static final LocalNotificationService _instance =
//       LocalNotificationService._internal();

//   factory LocalNotificationService() => _instance;

//   LocalNotificationService._internal();

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   /// Initialize the notification settings
//   Future<void> init() async {
//     // Android initialization
//     const AndroidInitializationSettings androidInitSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization
//     const DarwinInitializationSettings iosInitSettings =
//         DarwinInitializationSettings();

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//       iOS: iosInitSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tap
//         final payload = response.payload;
//         if (payload != null) {
//           print("Notification payload: $payload");
//           // You can add navigation logic here
//         }
//       },
//     );
//   }

//   /// Show simple notification
//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'puvi_channel', // channel id
//       'Puvi Notifications', // channel name
//       channelDescription: 'Channel for Puvi app notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//     );

//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);

//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformDetails,
//       payload: payload,
//     );
//   }

//   /// Schedule notification
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'puvi_channel',
//       'Puvi Notifications',
//       channelDescription: 'Channel for Puvi app notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledDate, tz.local),
//       const NotificationDetails(android: androidDetails),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode:
//           AndroidScheduleMode.exactAllowWhileIdle, // ✅ REQUIRED
//     );
//   }

//   /// Cancel all notifications
//   Future<void> cancelAll() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }
// }
