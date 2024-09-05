import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _localNotificationService = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationResponse> _notificationResponseStream = BehaviorSubject<NotificationResponse>();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@drawable/ic_stat_access_alarms');

    final DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _localNotificationService.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    _notificationResponseStream.listen((response) {
      print('Notification response received: ${response.payload}');
    });

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id',
      'channel_name',
      description: 'description',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationService.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      icon: 'ic_stat_access_alarms',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details, payload: payload);
  }

  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('id $id, title $title, body $body, payload $payload');
  }

  Future<void> onDidReceiveNotificationResponse(NotificationResponse details) async {
    String? payload = details.payload;
    print('Payload da notificação: $payload');
    if (payload != null) {
      print('Navegando ou realizando uma ação com o payload: $payload');
    }
  }
}
