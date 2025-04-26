import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String receiver;
  final String sender;
  final String content;
  final String type; // NewMember, Birthday, Event
  final int status; // 0: chưa xem, 1: đã xem
  final DateTime time;

  NotificationModel({
    required this.id,
    required this.receiver,
    required this.sender,
    required this.content,
    required this.type,
    required this.status,
    required this.time,
  });

  // Chuyển dữ liệu từ Firestore thành NotificationModel
  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      receiver: map['receiver'] ?? '',
      sender: map['sender'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? 0,
      time: (map['time'] as Timestamp).toDate(),
    );
  }

  // Chuyển NotificationModel => Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'receiver': receiver,
      'sender': sender,
      'content': content,
      'type': type,
      'status': status,
      'time': Timestamp.fromDate(time), // Firestore cần Timestamp
    };
  }
}
