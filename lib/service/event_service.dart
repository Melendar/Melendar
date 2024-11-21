import 'package:cloud_firestore/cloud_firestore.dart';
import '../calendar/firebase_event_data.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(String groupId, String task, DateTime date) async {
    try {
      await _firestore
          .collection('Groups')
          .doc(groupId)
          .collection('CalendarEvents')
          .add({
        'task': task,
        'date': date.toIso8601String(),
        'group_id': groupId,
      });
      print("캘린더 이벤트가 성공적으로 생성되었습니다.");
    } catch (e) {
      print("캘린더 이벤트 생성 중 오류 발생: $e");
    }
  }

  Future<List<FirebaseEventData>> getEventsByUser(String userId) async {
    List<FirebaseEventData> allEvents = [];

    try {
      QuerySnapshot groupSnapshot = await _firestore
          .collection('Groups')
          .where('members', arrayContains: userId)
          .get();

      for (var groupDoc in groupSnapshot.docs) {
        String groupId = groupDoc.id;

        QuerySnapshot eventSnapshot = await _firestore
            .collection('Groups')
            .doc(groupId)
            .collection('CalendarEvents')
            .get();

        for (var eventDoc in eventSnapshot.docs) {
          allEvents.add(FirebaseEventData.fromMap({
            'event_id': eventDoc.id,
            'group_id': groupId,
            'task': eventDoc['task'],
            'date': eventDoc['date'],
            'user_id': userId,
          }));
        }
      }
    } catch (e) {
      print("캘린더 이벤트 조회 중 오류 발생: $e");
    }

    return allEvents;
  }

  Future<void> updateEvent(
      String groupId, String eventId, String newTask) async {
    try {
      await _firestore
          .collection('Groups')
          .doc(groupId)
          .collection('CalendarEvents')
          .doc(eventId)
          .update({
        'task': newTask,
      });
      print("캘린더 이벤트가 성공적으로 업데이트되었습니다.");
    } catch (e) {
      print("캘린더 이벤트 업데이트 중 오류 발생: $e");
    }
  }

  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _firestore
          .collection('Groups')
          .doc(groupId)
          .collection('CalendarEvents')
          .doc(eventId)
          .delete();
      print("캘린더 이벤트가 성공적으로 삭제되었습니다.");
    } catch (e) {
      print("캘린더 이벤트 삭제 중 오류 발생: $e");
    }
  }
}
