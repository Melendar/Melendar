import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 특정 그룹에 캘린더 이벤트 생성
  Future<void> createEvent(String groupId, String task, DateTime date) async {
    try {
      await _firestore.collection('Groups').doc(groupId).collection('CalendarEvents').add({
        'task': task,
        'date': date.toIso8601String(),
        'group_id': groupId,
      });
      print("캘린더 이벤트가 성공적으로 생성되었습니다.");
    } catch (e) {
      print("캘린더 이벤트 생성 중 오류 발생: $e");
    }
  }

  /// 사용자가 속한 모든 그룹의 캘린더 이벤트 조회
  Future<List<Map<String, dynamic>>> getEventsByUser(String userId) async {
    List<Map<String, dynamic>> allEvents = [];

    try {
      // 사용자가 속한 모든 그룹 조회
      QuerySnapshot groupSnapshot = await _firestore.collection('Groups')
          .where('members', arrayContains: userId)
          .get();

      for (var groupDoc in groupSnapshot.docs) {
        String groupId = groupDoc.id;

        // 해당 그룹의 모든 캘린더 이벤트 조회
        QuerySnapshot eventSnapshot = await _firestore.collection('Groups')
            .doc(groupId)
            .collection('CalendarEvents')
            .get();

        for (var eventDoc in eventSnapshot.docs) {
          allEvents.add({
            'event_id': eventDoc.id,
            'group_id': groupId,
            'task': eventDoc['task'],
            'date': eventDoc['date'],
          });
        }
      }
    } catch (e) {
      print("캘린더 이벤트 조회 중 오류 발생: $e");
    }

    return allEvents;
  }

  /// 특정 이벤트 업데이트 (task만 수정)
  Future<void> updateEvent(String groupId, String eventId, String newTask) async {
    try {
      await _firestore.collection('Groups')
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

  /// 특정 이벤트 삭제
  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _firestore.collection('Groups')
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



/*
class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getCalendar(String userId) async {
    // 내 캘린더 불러오기
    QuerySnapshot snapshot = await _firestore.collection('events').where('userId', isEqualTo: userId).get();
    // snapshot 결과 처리
  }

  Future<void> createEvent(String groupId, String task, DateTime date) async {
    // 일정 추가
    await _firestore.collection('events').add({
      'groupId': groupId,
      'task': task,
      'date': date.toIso8601String(),
    });
  }

  Future<void> updateEvent(String eventId, String task, DateTime date) async {
    // 일정 수정
    await _firestore.collection('events').doc(eventId).update({
      'task': task,
      'date': date.toIso8601String(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    // 일정 삭제
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<void> searchEvents(String keyword) async {
    // 일정 검색
    QuerySnapshot snapshot = await _firestore.collection('events')
        .where('task', isGreaterThanOrEqualTo: keyword)
        .where('task', isLessThanOrEqualTo: '${keyword}\uf8ff')
        .get();
    // snapshot 결과 처리
  }
}
*/