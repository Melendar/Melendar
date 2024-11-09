import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'service/event_service.dart';
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
      title: 'Calendar Event Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EventTestPage(),
    );
  }
}

class EventTestPage extends StatefulWidget {
  const EventTestPage({super.key});

  @override
  _EventTestPageState createState() => _EventTestPageState();
}

class _EventTestPageState extends State<EventTestPage> {
  final EventService _eventService = EventService();

  // Controllers for input fields
  final TextEditingController _groupIdController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _eventIdController = TextEditingController();

  String _displayText = "캘린더 이벤트 테스트를 위한 버튼을 눌러보세요.";
  final String testUserId = "user1234"; // 고정된 userId

  // Event creation
  Future<void> _createEvent() async {
    String groupId = _groupIdController.text;
    String task = _taskController.text;
    DateTime date = DateTime.now(); // 현재 날짜를 이벤트 날짜로 설정

    await _eventService.createEvent(groupId, task, date);
    setState(() {
      _displayText = "새로운 캘린더 이벤트 '$task'가 그룹 $groupId에 생성되었습니다.";
    });
  }

  // Fetch events
  Future<void> _getEventsByUser() async {
    List<Map<String, dynamic>> events = await _eventService.getEventsByUser(testUserId);
    setState(() {
      _displayText = "조회된 이벤트: ${events.map((e) => e['task']).join(', ')}";
    });
  }

  // Update event
  Future<void> _updateEvent() async {
    String groupId = _groupIdController.text;
    String eventId = _eventIdController.text;
    String newTask = _taskController.text;

    await _eventService.updateEvent(groupId, eventId, newTask);
    setState(() {
      _displayText = "이벤트가 업데이트되었습니다.";
    });
  }

  // Delete event
  Future<void> _deleteEvent() async {
    String groupId = _groupIdController.text;
    String eventId = _eventIdController.text;

    await _eventService.deleteEvent(groupId, eventId);
    setState(() {
      _displayText = "이벤트가 삭제되었습니다.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Event Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _displayText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Input fields
              TextField(
                controller: _groupIdController,
                decoration: const InputDecoration(labelText: '그룹 ID'),
              ),
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(labelText: '이벤트 내용 (Task)'),
              ),
              TextField(
                controller: _eventIdController,
                decoration: const InputDecoration(labelText: '이벤트 ID (업데이트/삭제용)'),
              ),
              
              const SizedBox(height: 20),

              // Buttons for CRUD operations
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text('캘린더 이벤트 생성'),
              ),
              ElevatedButton(
                onPressed: _getEventsByUser,
                child: const Text('내 이벤트 조회'),
              ),
              ElevatedButton(
                onPressed: _updateEvent,
                child: const Text('이벤트 수정'),
              ),
              ElevatedButton(
                onPressed: _deleteEvent,
                child: const Text('이벤트 삭제'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
