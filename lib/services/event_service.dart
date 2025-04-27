import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/events.dart';

class EventService {
  static final _eventsCollection = FirebaseFirestore.instance.collection('events');

  static Future<List<Event>> loadEvents(String familyCode) async {
    final snapshot = await _eventsCollection
        .where('familyCode', isEqualTo: familyCode)
        .get();

    return snapshot.docs.map((doc) => Event.fromMap(doc.data(), doc.id)).toList();
  }

  static Future<void> addEvent({
    required DateTime day,
    required String time,
    required String title,
    required String location,
    required String familyCode,
  }) async {
    await _eventsCollection.add({
      'day': day,
      'time': time,
      'title': title,
      'location': location,
      'familyCode': familyCode,
      'isBirthday' : false,
      'owner' : '',
    });
  }

  static Future<void> updateEvent({
    required String eventId,
    required String time,
    required String title,
    required String location,
  }) async {
    await _eventsCollection.doc(eventId).update({
      'time': time,
      'title': title,
      'location': location,
    });
  }

  static Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  static Future<void> addBirthdayEvent(String userEmail, String userName, String familyCode, DateTime birthday) async {

    // Lấy ngày và tháng từ birthday (dữ liệu gốc)
    final int day = birthday.day;
    final int month = birthday.month;
    final int year = DateTime.now().year; // Lấy năm hiện tại

    // Tạo một DateTime mới với năm hiện tại và ngày, tháng từ birthday
    final DateTime eventDate = DateTime(year, month, day);

    final event = Event(
      id: '', // Firebase sẽ tạo ID tự động khi thêm
      day: eventDate,
      time: '00:00', // Bạn có thể định dạng thời gian theo nhu cầu
      title: '${userName}\'s Birthday On ${eventDate.day}/${eventDate.month}',
      location: 'Home',
      familyCode: familyCode,
      isBirthday: true,
      owner: userEmail,
    );

    await _eventsCollection.add({
      'day': event.day,
      'time': event.time,
      'title': event.title,
      'location': event.location,
      'familyCode': event.familyCode,
      'isBirthday': event.isBirthday,
      'owner': event.owner,
    });
  }
}
