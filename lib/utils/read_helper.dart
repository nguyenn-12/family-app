import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/providers/unread_provider.dart';

void listenUnreadMessages({
  required String familyCode,
  required String currentUserId,
  required UnreadProvider unreadProvider,
}) {
  FirebaseFirestore.instance
      .collection('families')
      .doc(familyCode)
      .collection('messages')
      .snapshots()
      .listen((snapshot) {
    int count = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final List readBy = data['readBy'] ?? [];
      final senderId = data['senderId'];
      return senderId != currentUserId && !readBy.contains(currentUserId);
    }).length;

    unreadProvider.setUnread(count);
  });
}

Future<void> markMessageAsRead({
  required String familyCode,
  required String messageId,
  required String userId,
}) async {
  final docRef = FirebaseFirestore.instance
      .collection('families')
      .doc(familyCode)
      .collection('messages')
      .doc(messageId);

  final doc = await docRef.get();
  if (doc.exists) {
    final readBy = List<String>.from(doc['readBy'] ?? []);
    if (!readBy.contains(userId)) {
      await docRef.update({
        'readBy': FieldValue.arrayUnion([userId])
      });
    }
  }
}