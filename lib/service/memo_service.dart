import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // intl 패키지 import

final FirebaseFirestore _firestore = FirebaseFirestore.instance;


// 메모 생성
Future<void> createMemo(String userId, String title, String content) async {
  if (userId.isEmpty || title.isEmpty || content.isEmpty) return;

  await _firestore.collection('Users').doc(userId).collection('Memos').add({
    'title': title,
    'content': content,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// 메모 업데이트
Future<void> updateMemo(String userId, String memoId, String title, String content) async {
  if (userId.isEmpty || memoId.isEmpty || title.isEmpty || content.isEmpty) return;

  await _firestore.collection('Users').doc(userId).collection('Memos').doc(memoId).update({
    'title': title,
    'content': content,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// 메모 삭제
Future<void> deleteMemo(String userId, String memoId) async {
  if (userId.isEmpty || memoId.isEmpty) return;

  await _firestore.collection('Users').doc(userId).collection('Memos').doc(memoId).delete();
}

// userId 값으로 메모 정보 가져오기
Future<List<Map<String, dynamic>>> fetchMemosByUserId(String userId) async {
  if (userId.isEmpty) return [];

  try {
    final querySnapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Memos')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      final date = timestamp != null ? timestamp.toDate().toString() : 'No Date';

      return {
        'memoId': doc.id,
        'title': data['title'] ?? '제목 없음',
        'content': data['content'] ?? '내용 없음',
        'date': date,
      };
    }).toList();
  } catch (e) {
    print('Error fetching memos: $e');
    return [];
  }
}
