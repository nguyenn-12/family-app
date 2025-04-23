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
}
