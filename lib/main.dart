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
      title: 'Firestore Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirestoreTestPage(),
    );
  }
}

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  _FirestoreTestPageState createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 그룹 추가
  Future<void> _addGroup(String groupName, String groupDescription) async {
    await _firestore.collection('Groups').add({
      'group_name': groupName,
      'group_description': groupDescription,
      'events': [],
      'members': [],
    });
  }

  // 캘린더 이벤트 추가
  Future<void> _addEvent(String groupId, String task, DateTime date) async {
    await _firestore.collection('CalendarEvents').add({
      'group_id': groupId,
      'task': task,
      'date': date.toIso8601String(),
    });
  }

  // 그룹 리스트 가져오기
  Future<void> _getGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('Groups').get();
    for (var doc in snapshot.docs) {
      print('Group ID: ${doc.id}');
      print('Group Name: ${doc['group_name']}');
      print('Group Description: ${doc['group_description']}');
    }
  }

  // 캘린더 이벤트 리스트 가져오기
  Future<void> _getEvents() async {
    QuerySnapshot snapshot = await _firestore.collection('CalendarEvents').get();
    for (var doc in snapshot.docs) {
      print('Event ID: ${doc.id}');
      print('Group ID: ${doc['group_id']}');
      print('Task: ${doc['task']}');
      print('Date: ${doc['date']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _addGroup('테스트 그룹', '이것은 테스트 그룹입니다'),
              child: const Text('그룹 추가하기'),
            ),
            ElevatedButton(
              onPressed: () => _addEvent('group123', '플러터 공부하기', DateTime.now()),
              child: const Text('캘린더 이벤트 추가하기'),
            ),
            ElevatedButton(
              onPressed: _getGroups,
              child: const Text('그룹 목록 가져오기'),
            ),
            ElevatedButton(
              onPressed: _getEvents,
              child: const Text('이벤트 목록 가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}
