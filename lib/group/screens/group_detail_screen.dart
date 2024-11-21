import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';
import 'group_management_screen.dart';

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
              showAddMemberPopup(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupManagementScreen(group: widget.group),
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
                          GestureDetector(
                            onTap: () {
                              _editUserName(userProfile.nickname);
                            },
                            child: Icon(Icons.edit, size: 18),
                          ),
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
                    itemCount: widget.group.members.length,
                    itemBuilder: (context, index) {
                      final memberId = widget.group.members[index];
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
                                  backgroundImage:
                                      userProfile.profileImage.isNotEmpty
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

  void _editUserName(String currentName) async {
    String newUserName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('이름 수정'),
            content: TextField(
              controller: TextEditingController(text: currentName),
              onSubmitted: (value) {
                Navigator.pop(context, value);
              },
              decoration: InputDecoration(hintText: '새 이름 입력'),
            ),
          ),
        ) ??
        currentName;

    if (newUserName != currentName) {
      final currentProfile = await _userProfileFuture;
      setState(() {
        _userProfileFuture = Future.value(UserProfile(
          id: widget.userId,
          nickname: newUserName,
          profileImage: currentProfile?.profileImage ?? '',
        ));
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('이름이 업데이트되었습니다.')));
    }
  }

  void showAddMemberPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('멤버 추가'),
          content: Container(
            width: double.maxFinite,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ID로 검색 후 추가',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      },
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