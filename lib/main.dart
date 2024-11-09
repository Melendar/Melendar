import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'service/group_service.dart';
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

  // Controllers for input fields
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final TextEditingController _groupIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController(); // 그룹원 추가와 그룹 나가기에 사용할 userId 입력 필드 추가

  String _displayText = "Firestore CRUD 테스트를 위한 버튼을 눌러보세요.";

  // Test userId for personal group creation
  final String testUserId = "user1234";

  Future<void> _createPersonalGroup() async {
    await _groupService.createPersonalGroup(testUserId);
    setState(() {
      _displayText = "개인그룹이 생성되었습니다.";
    });
  }

  Future<void> _createGroup() async {
    String groupName = _groupNameController.text;
    String groupDescription = _groupDescriptionController.text;
    await _groupService.createGroup(groupName, groupDescription, [testUserId]);
    setState(() {
      _displayText = "새로운 그룹 '$groupName'이 생성되었습니다.";
    });
  }

  Future<void> _getGroupsByUser() async {
    List<Map<String, dynamic>> groups = await _groupService.getGroupsByUser(testUserId);
    setState(() {
      _displayText = "조회된 그룹: ${groups.map((g) => g['group_name']).join(', ')}";
    });
  }

  Future<void> _updateGroup() async {
    String groupId = _groupIdController.text;
    String newGroupName = _groupNameController.text;
    String newGroupDescription = _groupDescriptionController.text;
    await _groupService.updateGroup(groupId, testUserId, newGroupName, newGroupDescription);
    setState(() {
      _displayText = "그룹 정보가 업데이트되었습니다.";
    });
  }

  Future<void> _leaveGroup() async {
    String groupId = _groupIdController.text;
    String userId = _userIdController.text;
    await _groupService.leaveGroup(groupId, userId);
    setState(() {
      _displayText = "사용자 '$userId'가 그룹에서 나갔습니다.";
    });
  }

  Future<void> _deleteGroup() async {
    String groupId = _groupIdController.text;
    await _groupService.deleteGroup(groupId);
    setState(() {
      _displayText = "그룹이 삭제되었습니다.";
    });
  }

  Future<void> _addGroupMember() async {
    String groupId = _groupIdController.text;
    // List<String> userId = _userIdController.text;
    List<String> userId = _userIdController.text.split(',').map((id) => id.trim()).toList();

    await _groupService.addGroupMember(groupId, userId);
    setState(() {
      _displayText = "사용자 '$userId'가 그룹에 추가되었습니다.";
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
                controller: _groupNameController,
                decoration: const InputDecoration(labelText: '그룹 이름'),
              ),
              TextField(
                controller: _groupDescriptionController,
                decoration: const InputDecoration(labelText: '그룹 설명'),
              ),
              TextField(
                controller: _groupIdController,
                decoration: const InputDecoration(labelText: '그룹 ID'),
              ),
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(labelText: '사용자 ID (그룹원 추가 및 나가기)'),
              ),
              
              const SizedBox(height: 20),

              // Buttons for CRUD operations
              ElevatedButton(
                onPressed: _createPersonalGroup,
                child: const Text('개인그룹 생성'),
              ),
              ElevatedButton(
                onPressed: _createGroup,
                child: const Text('그룹 생성'),
              ),
              ElevatedButton(
                onPressed: _getGroupsByUser,
                child: const Text('내 그룹 조회'),
              ),
              ElevatedButton(
                onPressed: _updateGroup,
                child: const Text('그룹 수정'),
              ),
              ElevatedButton(
                onPressed: _addGroupMember,
                child: const Text('그룹원 추가'),
              ),
              ElevatedButton(
                onPressed: _leaveGroup,
                child: const Text('그룹 나가기'),
              ),
              ElevatedButton(
                onPressed: _deleteGroup,
                child: const Text('그룹 삭제'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
