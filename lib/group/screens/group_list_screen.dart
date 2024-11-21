import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'add_group_screen.dart';
import '../../service/user_service.dart';
import '../../user_manage/user_provider.dart';

class GroupListScreen extends StatelessWidget {
  final Map<String, Future<UserProfile?>> userCache = {};

  Future<UserProfile?> getUserProfile(String userId) {
    return userCache.putIfAbsent(userId, () => fetchUserById(userId));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.user?.displayName ?? '사용자';
    final userId = userProvider.user?.uid;

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
                  builder: (context) => AddGroupScreen(userId: userId),
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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final groups = userProvider.groups
              .map((groupData) => Group(
                    id: groupData['group_id'],
                    name: groupData['group_name'],
                    description: groupData['group_description'],
                    members: List<String>.from(groupData['members']),
                  ))
              .toList();

          return groups.isEmpty
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
                              userId: userId ?? '',
                              getUserProfile: getUserProfile,
                            ),
                          ),
                        );
                      },
                      child: GroupCard(
                        group: groups[index],
                        getUserProfile: getUserProfile,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}