import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final DateTime day;
  final String time; // Format: 'HH:mm'
  final String title;
  final String location;
  final String familyCode;

  Event({
    required this.id,
    required this.day,
    required this.time,
    required this.title,
    required this.location,
    required this.familyCode,
  });

  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      day: (data['day'] as Timestamp).toDate(),
      time: data['time'] ?? '', // tránh lỗi null
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      familyCode: data['familyCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'time': time,
      'title': title,
      'location': location,
      'familyCode': familyCode,
    };
  }
}
