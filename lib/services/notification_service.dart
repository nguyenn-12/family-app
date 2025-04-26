import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/notifications.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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


}
