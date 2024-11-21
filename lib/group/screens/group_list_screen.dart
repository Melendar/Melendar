import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'add_group_screen.dart';
import '../../user_manage/user_provider.dart';

class GroupListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.displayName ?? '사용자';
    final groups = userProvider.groups
        .map((groupData) => Group(
              id: groupData['group_id'],
              name: groupData['group_name'],
              description: groupData['group_description'],
              members: List<String>.from(groupData['members']),
              isAdmin: groupData['members'][0] == userProvider.user?.uid,
            ))
        .toList();

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
              );
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
      body: groups.isEmpty
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
