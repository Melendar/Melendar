import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/group_service.dart'; // 프로젝트 구조에 맞게 import 경로 조정

class AddGroupScreen extends StatefulWidget {
  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final GroupService _eventService = GroupService();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  final TextEditingController _memberIdsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('그룹 추가')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: '그룹 이름'),
            ),
            TextField(
              controller: _groupDescriptionController,
              decoration: InputDecoration(labelText: '그룹 설명'),
            ),
            TextField(
              controller: _memberIdsController,
              decoration: InputDecoration(labelText: '구성원 ID (쉼표로 구분)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('그룹 생성'),
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup() async {
    String groupName = _groupNameController.text;
    String groupDescription = _groupDescriptionController.text;
    List<String> memberIds =
        _memberIdsController.text.split(',').map((id) => id.trim()).toList();

    await _eventService.createGroup(groupName, groupDescription, memberIds);
    // 그룹 생성 후 필요한 네비게이션이나 확인 메시지 처리 > 화면끄기, 성공메시지
  }
}
