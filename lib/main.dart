import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore CRUD Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirestoreTestPage(),
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 그룹 추가
  Future<void> addGroup(String groupName, String groupDescription) async {
    await _firestore.collection('Groups').add({
      'group_name': groupName,
      'group_description': groupDescription,
      'members': [],
    });
  }

  // 그룹 업데이트
  Future<void> updateGroup(String groupId, String groupName, String groupDescription) async {
    await _firestore.collection('Groups').doc(groupId).update({
      'group_name': groupName,
      'group_description': groupDescription,
    });
  }

  // 그룹 삭제
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('Groups').doc(groupId).delete();
  }

  // 그룹 목록 가져오기
  Future<List<QueryDocumentSnapshot>> getGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('Groups').get();
    return snapshot.docs;
  }

  // 캘린더 이벤트 추가
  Future<void> addEvent(String groupId, String task, DateTime date) async {
    await _firestore.collection('Groups').doc(groupId).collection('CalendarEvents').add({
      'task': task,
      'date': date.toIso8601String(),
    });
  }

  // 캘린더 이벤트 목록 가져오기
  Future<List<QueryDocumentSnapshot>> getEvents(String groupId) async {
    QuerySnapshot snapshot = await _firestore.collection('Groups').doc(groupId).collection('CalendarEvents').get();
    return snapshot.docs;
  }

  // 캘린더 이벤트 삭제
  Future<void> deleteEvent(String groupId, String eventId) async {
    await _firestore.collection('Groups').doc(groupId).collection('CalendarEvents').doc(eventId).delete();
  }
}

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  _FirestoreTestPageState createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _displayText = "버튼을 눌러 Firestore 작업을 테스트해 보세요.";

  // 그룹 추가
  Future<void> _addGroup() async {
    await _firestoreService.addGroup("테스트 그룹", "이것은 테스트 그룹입니다");
    setState(() {
      _displayText = "그룹이 추가되었습니다.";
    });
  }

  // 그룹 목록 가져오기
  Future<void> _getGroups() async {
    List<QueryDocumentSnapshot> groups = await _firestoreService.getGroups();
    setState(() {
      _displayText = "그룹 목록: ${groups.map((g) => g['group_name']).toList()}";
    });
  }

  // 그룹 업데이트
  Future<void> _updateGroup(String groupId) async {
    await _firestoreService.updateGroup(groupId, "업데이트된 그룹", "업데이트된 설명입니다");
    setState(() {
      _displayText = "그룹이 업데이트되었습니다.";
    });
  }

  // 그룹 삭제
  Future<void> _deleteGroup(String groupId) async {
    await _firestoreService.deleteGroup(groupId);
    setState(() {
      _displayText = "그룹이 삭제되었습니다.";
    });
  }

  // 이벤트 추가
  Future<void> _addEvent(String groupId) async {
    await _firestoreService.addEvent(groupId, "플러터 공부하기", DateTime.now());
    setState(() {
      _displayText = "이벤트가 추가되었습니다.";
    });
  }

  // 이벤트 목록 가져오기
  Future<void> _getEvents(String groupId) async {
    List<QueryDocumentSnapshot> events = await _firestoreService.getEvents(groupId);
    setState(() {
      _displayText = "이벤트 목록: ${events.map((e) => e['task']).toList()}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore CRUD Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _displayText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addGroup,
              child: const Text('그룹 추가하기'),
            ),
            ElevatedButton(
              onPressed: _getGroups,
              child: const Text('그룹 목록 가져오기'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<QueryDocumentSnapshot> groups = await _firestoreService.getGroups();
                if (groups.isNotEmpty) {
                  _updateGroup(groups.first.id);
                }
              },
              child: const Text('그룹 업데이트하기'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<QueryDocumentSnapshot> groups = await _firestoreService.getGroups();
                if (groups.isNotEmpty) {
                  _deleteGroup(groups.first.id);
                }
              },
              child: const Text('그룹 삭제하기'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<QueryDocumentSnapshot> groups = await _firestoreService.getGroups();
                if (groups.isNotEmpty) {
                  _addEvent(groups.first.id);
                }
              },
              child: const Text('이벤트 추가하기'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<QueryDocumentSnapshot> groups = await _firestoreService.getGroups();
                if (groups.isNotEmpty) {
                  _getEvents(groups.first.id);
                }
              },
              child: const Text('이벤트 목록 가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}
