import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/group_service.dart';
import '../../user_manage/user_provider.dart';

class AddGroupScreen extends StatefulWidget {
  final String? userId;

  const AddGroupScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final GroupService _eventService = GroupService();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  List<TextEditingController> _memberIdControllers = [];

  @override
  void initState() {
    super.initState();
    _addMemberIdField();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
          title: Text('그룹 추가')),
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              SizedBox(height: 20),
              ..._memberIdControllers
                  .map((controller) => TextField(
                        controller: controller,
                        decoration: InputDecoration(labelText: '구성원 ID'),
                        onChanged: (value) {
                          // 본인 id는 추가 못하게
                          if (value == widget.userId) {
                            controller.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('자신의 ID는 추가할 수 없습니다.')),
                            );
                            return;
                          }
                          // 멤버 id칸에 뭐 쓰면 빈 id칸 하나 추가. 다른 사람도 추가할 수 있게.
                          if (value.isNotEmpty &&
                              controller == _memberIdControllers.last) {
                            _addMemberIdField();
                          }
                        },
                      ))
                  .toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 버튼 배경색
                  foregroundColor: Colors.white, // 텍스트 색상
                ),
                child: Text('그룹 생성'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMemberIdField() {
    setState(() {
      _memberIdControllers.add(TextEditingController());
    });
  }

  void _createGroup() async {
    String groupName = _groupNameController.text;
    String groupDescription = _groupDescriptionController.text;

    // 빈 값이 아닌 멤버 ID만 필터링하여 리스트 생성
    List<String> memberIds = _memberIdControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .toList();

    // 현재 사용자 ID를 멤버 목록에 추가 (중복 방지)
    if (widget.userId != null && !memberIds.contains(widget.userId)) {
      memberIds.insert(0, widget.userId!);
    }

    try {
      await _eventService.createGroup(groupName, groupDescription, memberIds);

      // 그룹 생성 성공 시 UserProvider의 fetchGroups 호출
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchGroups();
        _showSuccessPopup(groupName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('그룹 생성 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 성공 알리고 전 페이지로 돌아감
  void _showSuccessPopup(String groupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('성공'),
        content: Text('$groupName 그룹이 생성되었습니다.'),
        actions: <Widget>[
          TextButton(
            child: Text('확인'),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 이전 페이지로 돌아가기
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러들 해제
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    for (var controller in _memberIdControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
