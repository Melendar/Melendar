import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'add_group_screen.dart';
import '../../service/user_service.dart';
import '../../service/group_service.dart';
import '../../user_manage/user_provider.dart';

class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final Map<String, Future<UserProfile?>> userCache = {};
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchGroups();
  }

  Future<UserProfile?> getUserProfile(String userId) {
    return userCache.putIfAbsent(userId, () => fetchUserById(userId));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
        title: Text('그룹'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GroupSearchDelegate(
                  groups: userProvider.groups,
                  userProvider: userProvider,
                  getUserProfile: getUserProfile,
                  userId: userId ?? '',
                ),
              );
            },
          ),
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
        ],
      ),
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final groups = userProvider.groups
              .map((groupData) => Group(
                    id: groupData['group_id'],
                    name: groupData['group_name'].trim(), // 개인그룹 하고 공백 뒤에 하나 있는듯...
                    description: groupData['group_description'],
                    members: List<String>.from(groupData['members']),
                  ))
              .where((group) => group.name != "개인그룹") // "개인그룹" 제외
              .toList();

          return groups.isEmpty
              ? Center(child: Text('참여 중인 그룹이 없습니다.'))
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        final groupsData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailScreen(
                              group: groups[index],
                              userId: userId ?? '',
                              getUserProfile: getUserProfile,
                            ),
                          ),
                        );
                        
                        if (groupsData != null && groupsData is List<Map<String, dynamic>>) {
                          // 삭제된 그룹의 색상도 제거
                          final newGroupIds = groupsData.map((g) => g['group_id'] as String).toSet();
                          final oldGroupIds = userProvider.groups.map((g) => g['group_id'] as String).toSet();
                          final removedGroupIds = oldGroupIds.difference(newGroupIds);
                          
                          for (String groupId in removedGroupIds) {
                            userProvider.removeGroupColor(groupId);
                          }
                          
                          Provider.of<UserProvider>(context, listen: false).updateGroups(groupsData);
                        }
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

class GroupSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> groups;
  final UserProvider userProvider;
  final Future<UserProfile?> Function(String) getUserProfile;
  final String userId;

  GroupSearchDelegate({
    required this.groups,
    required this.userProvider,
    required this.getUserProfile,
    required this.userId,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredGroups = groups.where((group) {
      final name = group['group_name'].toString().toLowerCase();
      final description = group['group_description'].toString().toLowerCase();
      final members = List<String>.from(group['members'])
          .map((memberId) => userProvider.getMemberNickname(memberId).toLowerCase())
          .toList();
          
      return name.contains(query.toLowerCase()) ||
             description.contains(query.toLowerCase()) ||
             members.any((nickname) => nickname.contains(query.toLowerCase()));
    }).toList();

    return filteredGroups.isEmpty
        ? Center(child: Text('검색 결과가 없습니다.'))
        : ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = Group(
                id: filteredGroups[index]['group_id'],
                name: filteredGroups[index]['group_name'],
                description: filteredGroups[index]['group_description'],
                members: List<String>.from(filteredGroups[index]['members']),
              );
              
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                        group: group,
                        userId: userId ?? '',
                        getUserProfile: getUserProfile,
                      ),
                    ),
                  );
                  
                  if (result != null && result is List<Map<String, dynamic>>) {
                    // 삭제된 그룹의 색상도 제거
                    final newGroupIds = result.map((g) => g['group_id'] as String).toSet();
                    final oldGroupIds = groups.map((g) => g['group_id'] as String).toSet();
                    final removedGroupIds = oldGroupIds.difference(newGroupIds);
                    
                    for (String groupId in removedGroupIds) {
                      userProvider.removeGroupColor(groupId);
                    }
                    
                    Provider.of<UserProvider>(context, listen: false).updateGroups(result);
                  }
                  close(context, result);
                },
                child: GroupCard(
                  group: group,
                  getUserProfile: getUserProfile,
                ),
              );
            },
          );
  }
}