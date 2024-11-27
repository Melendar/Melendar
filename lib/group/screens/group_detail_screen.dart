import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';
import '../../service/user_service.dart';
import '../../service/group_service.dart';
import '../../user_manage/user_provider.dart';

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
  late Group _group;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userProfileFuture = widget.getUserProfile(widget.userId);
    _group = widget.group;
    _nameController.text = _group.name;
    _descriptionController.text = _group.description;
  }

  Future<void> _updateGroupInfo(String field) async {
    final controller = field == 'name' ? _nameController : _descriptionController;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(field == 'name' ? '그룹명 수정' : '그룹 설명 수정'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field == 'name' ? '새로운 그룹명 입력' : '새로운 그룹 설명 입력',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('저장'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final groupService = GroupService();
        await groupService.updateGroup(
          _group.id,
          widget.userId,
          field == 'name' ? result : _group.name,
          field == 'description' ? result : _group.description,
        );

        final updatedGroup = await groupService.fetchSingleGroup(_group.id);
        if (updatedGroup != null) {
          setState(() {
            _group = updatedGroup;
          });

          final List<Map<String, dynamic>>? groupsData = 
              await groupService.getGroupsByUser(widget.userId);
          if (groupsData != null) {
            Provider.of<UserProvider>(context, listen: false)
                .updateGroups(groupsData);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('그룹 정보 업데이트 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            final groupService = GroupService();            
            final List<Map<String, dynamic>>? groupsData =
                await groupService.getGroupsByUser(widget.userId);
            Navigator.pop(context, groupsData);
            },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              final updatedGroup = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemberScreen(groupId: _group.id),
                ),
              );
              if (updatedGroup != null) {
                setState(() {
                  _group = updatedGroup;
                });
              }
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _group.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => _updateGroupInfo('name'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _group.description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => _updateGroupInfo('description'),
                    ),
                  ],
                ),
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
                    itemCount:
                        _group.members.where((id) => id != widget.userId).length,
                    itemBuilder: (context, index) {
                      final memberId = _group.members
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
              onPressed: () async {
                try {
                  final groupService = GroupService();
                  await groupService.leaveGroup(_group.id, widget.userId);
                  final List<Map<String, dynamic>>? groupsData =
                      await groupService.getGroupsByUser(widget.userId);
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(groupsData); // 현재 화면을 닫으며 업데이트된 그룹 리스트 전달
                } catch (e) {
                  print("오류 발생: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("그룹 나가기 중 오류가 발생했습니다.")),
                  );
                  Navigator.of(context).pop(); // 다이얼로그만 닫기
                }
              },
              child: Text('네'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      try {
        final groupService = GroupService();
        await groupService.addGroupMember(
            widget.groupId, [_searchResult!.id]);
        
        Group? updatedGroup =
            await groupService.fetchSingleGroup(widget.groupId);
        if (updatedGroup != null) {
          Navigator.pop(context, updatedGroup);
        } else {
          throw Exception("Updated group not found");
        }
      } catch (e) {
        print("오류 발생: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("그룹 정보 업데이트 중 오류가 발생했습니다.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
        title: Text('멤버 추가')),
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
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