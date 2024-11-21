import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupManagementScreen extends StatefulWidget {
  final Group group;

  const GroupManagementScreen({Key? key, required this.group}) : super(key: key);

  @override
  _GroupManagementScreenState createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  late TextEditingController _groupNameController;
  late TextEditingController _groupDescriptionController;
  int groupNameMaxLength = 20;
  int groupDescriptionMaxLength = 50;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.name);
    _groupDescriptionController = TextEditingController(text: widget.group.description);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('그룹 관리'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), 
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그룹명 수정 필드
                TextField(
                  controller: _groupNameController,
                  maxLength: groupNameMaxLength,
                  decoration: InputDecoration(
                    labelText: '그룹명',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 그룹 설명 수정 필드
                TextField(
                  controller: _groupDescriptionController,
                  maxLength: groupDescriptionMaxLength,
                  decoration: InputDecoration(
                    labelText: '그룹 설명',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 멤버 목록 및 추방 기능
                Text('멤버'),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.group.members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text(widget.group.members[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            // 현재는 UI만 구현, 추후 API 연동 시 삭제 기능 추가 가능
                            setState(() {
                              widget.group.members.removeAt(index); // 로컬 상태에서만 삭제
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}