import 'package:flutter/material.dart';
import '../models/group_model.dart';
import 'group_management_screen.dart'; // 그룹 관리 화면 import

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  final String userName;

  const GroupDetailScreen({
    Key? key,
    required this.group,
    required this.userName,
  }) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late String userName;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              showAddMemberPopup(context); // 멤버 추가 팝업 호출
            },
          ),
          if (widget.group.isAdmin)
            IconButton(
              icon: Icon(Icons.settings), // 환경설정 아이콘
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupManagementScreen(group: widget.group),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showExitGroupPopup(context, widget.group.isAdmin); // 그룹 나가기 팝업 호출
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 전체적인 패딩 적용
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded Box 적용
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 카드 내부 패딩
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그룹명과 그룹 설명
                Text(
                  widget.group.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 8),
                Text(widget.group.description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),

                // 사용자 프로필 사진과 이름 (좌측 정렬 통일)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      // 사용자 프로필 사진 추가
                      child: Icon(Icons.person), // 더미 아이콘 (추후 실제 이미지로 대체 가능)
                    ),
                    SizedBox(width: 8), // 프로필 사진과 이름 사이 간격
                    Text(userName, style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _editUserName();
                      },
                      child: Icon(Icons.edit, size: 18),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // hr (rounded box와 같은 두께)
                Container(
                  height: 2,
                  width: double.infinity,
                  color:
                      Colors.teal.withOpacity(0.5), // rounded box와 같은 색상 및 두께
                ),
                SizedBox(height: 16),

                // 멤버 리스트 (좌측 정렬 통일)
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.group.members.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0), // 좌측 여백 통일
                          child: Row(
                            // ListTile 대신 Row로 직접 구성하여 좌측 정렬 통일
                            children: [
                              CircleAvatar(child: Icon(Icons.person)),
                              SizedBox(width: 8),
                              Text(widget.group.members[index]),
                            ],
                          ));
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editUserName() async {
    String newUserName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('이름 수정'),
            content: TextField(
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
                decoration: InputDecoration(hintText: '새 이름 입력')),
          ),
        ) ??
        userName;

    setState(() {
      userName = newUserName;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('백에 바뀐 이름 보내기')));
  }

// 멤버 추가 팝업 함수
  void showAddMemberPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded Box 적용
          ),
          title: Text('멤버 추가'),
          content: Container(
            width: double.maxFinite,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ID로 검색 후 추가',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded Box 적용
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// 그룹 나가기 팝업 함수
  void showExitGroupPopup(BuildContext context, bool isAdmin) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title:
                  Text(isAdmin ? '당신은 관리자입니다. 그룹에서 나가시겠습니까?' : '그룹에서 나가시겠습니까?'),
              actionsAlignment: MainAxisAlignment.center, // 버튼 중앙 정렬

              actionsPadding: EdgeInsets.symmetric(horizontal: 8),
              actions: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('아니오', style: TextStyle(color: Colors.blue))),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('네')),
              ]);
        });
  }
}
