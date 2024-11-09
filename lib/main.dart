import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './service/group_service.dart';
import './service/event_service.dart';
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

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  _FirestoreTestPageState createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  final GroupService _groupService = GroupService();
  final EventService _eventService = EventService();
  String _displayText = "버튼을 눌러 Firestore 작업을 테스트해 보세요.";

  Future<void> _createGroup() async {
    await _groupService.createGroup("테스트 그룹");
    setState(() {
      _displayText = "그룹이 추가되었습니다.";
    });
  }

  Future<void> _getGroups(String userId) async {
    await _groupService.getGroups(userId);
    setState(() {
      _displayText = "그룹 목록을 불러왔습니다.";
    });
  }

  Future<void> _updateGroup(String userGroupId) async {
    await _groupService.updateGroup(userGroupId, description: "Updated description");
    setState(() {
      _displayText = "그룹이 수정되었습니다.";
    });
  }

  Future<void> _leaveGroup(String userGroupId) async {
    await _groupService.leaveGroup(userGroupId);
    setState(() {
      _displayText = "그룹에서 나갔습니다.";
    });
  }

  Future<void> _addGroupMember(String userId, String groupId) async {
    await _groupService.addGroupMember(userId, groupId);
    setState(() {
      _displayText = "그룹원이 추가되었습니다.";
    });
  }

  Future<void> _getCalendar(String userId) async {
    await _eventService.getCalendar(userId);
    setState(() {
      _displayText = "캘린더를 불러왔습니다.";
    });
  }

  Future<void> _createEvent(String groupId) async {
    await _eventService.createEvent(groupId, "테스트 일정", DateTime.now());
    setState(() {
      _displayText = "일정이 추가되었습니다.";
    });
  }

  Future<void> _updateEvent(String eventId) async {
    await _eventService.updateEvent(eventId, "업데이트된 일정", DateTime.now());
    setState(() {
      _displayText = "일정이 수정되었습니다.";
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    await _eventService.deleteEvent(eventId);
    setState(() {
      _displayText = "일정이 삭제되었습니다.";
    });
  }

  Future<void> _searchEvents(String keyword) async {
    await _eventService.searchEvents(keyword);
    setState(() {
      _displayText = "일정 검색 결과를 불러왔습니다.";
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
              onPressed: _createGroup,
              child: const Text('그룹 추가하기'),
            ),
            ElevatedButton(
              onPressed: () => _getGroups("userId1"),
              child: const Text('내 그룹 불러오기'),
            ),
            ElevatedButton(
              onPressed: () => _updateGroup("userGroupId1"),
              child: const Text('그룹 수정하기'),
            ),
            ElevatedButton(
              onPressed: () => _leaveGroup("userGroupId1"),
              child: const Text('그룹 나가기'),
            ),
            ElevatedButton(
              onPressed: () => _addGroupMember("userId1", "groupId1"),
              child: const Text('그룹원 추가하기'),
            ),
            ElevatedButton(
              onPressed: () => _getCalendar("userId1"),
              child: const Text('내 캘린더 불러오기'),
            ),
            ElevatedButton(
              onPressed: () => _createEvent("groupId1"),
              child: const Text('일정 추가하기'),
            ),
            ElevatedButton(
              onPressed: () => _updateEvent("eventId1"),
              child: const Text('일정 수정하기'),
            ),
            ElevatedButton(
              onPressed: () => _deleteEvent("eventId1"),
              child: const Text('일정 삭제하기'),
            ),
            ElevatedButton(
              onPressed: () => _searchEvents("keyword"),
              child: const Text('일정 검색하기'),
            ),
          ],
        ),
      ),
    );
  }
}
