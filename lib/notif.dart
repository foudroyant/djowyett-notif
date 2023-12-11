
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notif {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future _notificationDetails()async {
    return NotificationDetails(
      //android: AndroidNotificationDetails(),
      //iOS: DarwinNotificationDetails()
    );
  }

  Future showNotif({
    int id=0,
    String? title,
    String? body,
    String? payload,
}) async => _notification.show(id, title, body, await _notificationDetails(), payload: payload);
}