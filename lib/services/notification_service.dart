import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference notificationCollection = FirebaseFirestore.instance.collection('notifications');

  // Fetch các thông báo theo email người nhận
  Future<List<NotificationModel>> fetchNotificationsByReceiver(String receiverEmail) async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('receiver', isEqualTo: receiverEmail)
        .orderBy('time', descending: true)
        .get();

    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> updateNotificationStatus(String id, int newStatus) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({
      'status': newStatus,
    });
  }

  Future<Map<String, dynamic>> fetchUserByEmail(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    } else {
      throw Exception('User not found');
    }
  }

  static Future<void> addNotification(NotificationModel notification) async {
    try {
      await notificationCollection.add({
        'receiver': notification.receiver,
        'sender': notification.sender,
        'content': notification.content,
        'type': notification.type,
        'status': notification.status,
        'show': notification.show,
        'time': notification.time,
      });
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Stream<List<NotificationModel>> streamNotificationsByReceiver(String email) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('receiver', isEqualTo: email)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Stream<bool> hasUnreadNotifications(String email) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('receiver', isEqualTo: email)
        .where('status', isEqualTo: 0) // Chỉ lấy notification chưa đọc
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }



}
