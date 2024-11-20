import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'add_group_screen.dart';
import '../../user_provider.dart';
import '../services/group_service.dart'; // GroupService를 import

class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId != null) {
      final groupService = GroupService(); // GroupService 인스턴스 생성
      final groupsData = await groupService.getGroupsByUser(userId);

      setState(() {
        groups = groupsData
            .map((data) => Group(
                  id: data['group_id'],
                  name: data['group_name'],
                  description: data['group_description'],
                  members: List<String>.from(data['members']),
                  isAdmin: data['members'][0] == userId, // 첫 번째 멤버를 관리자로 가정
                ))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.displayName ?? '사용자';

    return Scaffold(
      appBar: AppBar(
        title: Text('그룹'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGroupScreen(),
                ),
              ).then((_) => _loadGroups()); // 그룹 추가 후 목록 새로고침
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? Center(child: Text('참여 중인 그룹이 없습니다.'))
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailScreen(
                              group: groups[index],
                              userName: userName,
                            ),
                          ),
                        );
                      },
                      child: GroupCard(group: groups[index]),
                    );
                  },
                ),
    );
  }
}
