import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';
import 'group_management_screen.dart';
import '../../service/group_service.dart';
import 'package:provider/provider.dart';
import '../../user_manage/user_provider.dart';
import '../../service/user_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  final String userId;
  final Future<UserProfile?> Function(String) getUserProfile;

  const GroupDetailScreen({
    Key? key,
    required this.group,
    required this.userId,
    required this.getUserProfile,
  }) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Future<UserProfile?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = widget.getUserProfile(widget.userId);
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddMemberScreen(groupId: widget.group.id),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
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
              showExitGroupPopup(context);
            },
          ),
        ],
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
                Text(
                  widget.group.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                Text(widget.group.description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                FutureBuilder<UserProfile?>(
                  future: _userProfileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final userProfile = snapshot.data!;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: userProfile.profileImage.isNotEmpty
                                ? NetworkImage(userProfile.profileImage)
                                : null,
                            child: userProfile.profileImage.isEmpty
                                ? Icon(Icons.person)
                                : null,
                          ),
                          SizedBox(width: 8),
                          Text(userProfile.nickname,
                              style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                        ],
                      );
                    } else {
                      return Text('User not found',
                          style: TextStyle(fontSize: 18));
                    }
                  },
                ),
                SizedBox(height: 16),
                Container(
                  height: 2,
                  width: double.infinity,
                  color: Colors.teal.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.group.members
                        .where((id) => id != widget.userId)
                        .length,
                    itemBuilder: (context, index) {
                      final memberId = widget.group.members
                          .where((id) => id != widget.userId)
                          .toList()[index];
                      return FutureBuilder<UserProfile?>(
                        future: widget.getUserProfile(memberId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                      child: CircularProgressIndicator()),
                                  SizedBox(width: 8),
                                  Text('로딩 중...'),
                                ],
                              ),
                            );
                          }
                          final userProfile = snapshot.data;
                          if (userProfile == null) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  CircleAvatar(child: Icon(Icons.person)),
                                  SizedBox(width: 8),
                                  Text(memberId),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: userProfile
                                          .profileImage.isNotEmpty
                                      ? NetworkImage(userProfile.profileImage)
                                      : null,
                                  child: userProfile.profileImage.isEmpty
                                      ? Icon(Icons.person)
                                      : null,
                                ),
                                SizedBox(width: 8),
                                Text(userProfile.nickname),
                              ],
                            ),
                          );
                        },
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

  void showExitGroupPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('그룹에서 나가시겠습니까?'),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('아니오', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('네'),
            ),
          ],
        );
      },
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  final String groupId;

  AddMemberScreen({required this.groupId});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  UserProfile? _searchResult;

  void _searchUser() async {
    if (_searchController.text.isEmpty) return;

    final result = await fetchUserById(_searchController.text);
    setState(() {
      _searchResult = result;
    });
  }

  void _addMember() async {
    if (_searchResult == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('멤버 추가'),
        content: Text('${_searchResult!.nickname}님을 그룹에 추가하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('추가'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final groupService = GroupService();
      await groupService.addGroupMember(widget.groupId, [_searchResult!.id]);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchGroups();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('멤버 추가')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '사용자 ID 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchUser,
                  child: Text('검색'),
                ),
              ],
            ),
            if (_searchResult != null) ...[
              SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: _searchResult!.profileImage.isNotEmpty
                      ? NetworkImage(_searchResult!.profileImage)
                      : null,
                  child: _searchResult!.profileImage.isEmpty
                      ? Icon(Icons.person)
                      : null,
                ),
                title: Text(_searchResult!.nickname),
                subtitle: Text(_searchResult!.id),
                trailing: ElevatedButton(
                  onPressed: _addMember,
                  child: Text('추가'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
