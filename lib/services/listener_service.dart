// 📄 listener_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:family/models/users.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void setupNotificationListeners(UserModel user) {
  _listenNewMessages(user);
  _listenGeneralNotifications(user);
}

void _listenNewMessages(UserModel user) {
  FirebaseFirestore.instance
      .collection('families')
      .doc(user.familyCode)
      .collection('messages')
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final List readBy = data['readBy'] ?? [];
      if (data['senderId'] != user.id && !readBy.contains(user.id)) {
        _showLocalNotification(
          title: "New Message",
          body: "You have a new message from ${data['senderName']}.",
        );
        break;
      }
    }
  });
}

void _listenGeneralNotifications(UserModel user) {
  FirebaseFirestore.instance
      .collection('notifications')
      .where('receiver', isEqualTo: user.email)
      .where('status', isEqualTo: 0)
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _showLocalNotification(
        title: _mapNotificationTypeToTitle(data['type']),
        body: data['content'],
      );

      // ✅ Đánh dấu đã gửi để không show lại
      doc.reference.update({'status': 1});
    }
  });
}


String _mapNotificationTypeToTitle(String type) {
  switch (type) {
    case 'NewMember':
      return 'New Join Request';
    case 'Birthday':
      return 'Birthday Reminder';
    case 'Event':
      return 'Event Updated';
    default:
      return 'Family App Notification';
  }
}

Future<void> _showLocalNotification({required String title, required String body}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Family Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    notificationDetails,
  );
}
