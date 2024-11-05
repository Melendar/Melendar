import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 그룹명과 관리자 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.name,
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (group.isAdmin)
                  Text('관리자', style: TextStyle(color: Colors.green)),
              ],
            ),
            SizedBox(height: 8),
            // 그룹 설명
            Text(group.description),
            SizedBox(height: 8),
            // 멤버 목록 표시
            _buildMembersRow(),
          ],
        ),
      ),
    );
  }

  // 멤버 목록을 한 줄로 표시하고, 초과 인원은 '외 n명'으로 처리
  Widget _buildMembersRow() {
    int maxVisibleMembers = 3; // 한 줄에 최대 표시할 멤버 수
    List<String> visibleMembers = group.members.take(maxVisibleMembers).toList();
    int remainingMembers = group.members.length - maxVisibleMembers;

    return Row(
      children: [
        ...visibleMembers.map((member) => _buildMemberAvatar(member)).toList(),
        if (remainingMembers > 0)
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Text('외 $remainingMembers명'),
          ),
      ],
    );
  }

  // 프로필 사진과 이름을 옆으로 배치
  Widget _buildMemberAvatar(String memberName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 4), // 프로필 사진과 이름 사이 간격
          Container(
            width: 50, // 이름의 최대 너비를 설정하여 너무 길면 잘리도록 함
            child: Text(
              memberName,
              overflow: TextOverflow.ellipsis, // 너무 긴 이름은 ...으로 처리
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}