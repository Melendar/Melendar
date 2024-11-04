import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart'; // 새로운 상세 페이지 import
import 'add_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  final String userName = '이승언'; // 사용자명 더미 데이터

  final List<Group> groups = [
    Group(
      name: '그룹 1',
      description: '그룹 설명',
      members: ['홍길동', '홍길동', '홍길동'],
      isAdmin: true,
    ),
    Group(
      name: '그룹 2',
      description: '그룹 설명',
      members: ['홍길동', '홍길동', '홍길동', 'ㅇㅇ', 'ㅇㅇ'],
      isAdmin: false,
    ),
    Group(
      name: '그룹 3',
      description: '그룹 설명',
      members: ['아주긴이름', '홍길동', '홍길동'],
      isAdmin: true,
    ),
    Group(
      name: '그룹 4',
      description: '그룹 설명',
      members: ['홍길동', '홍길동', '으아아아아', 'ㅇㅇ', 'ㅇㅇ'],
      isAdmin: false,
    ),
    Group(
      name: '그룹 5',
      description: '그룹 설명',
      members: ['홍길동', '홍길동', '홍길동'],
      isAdmin: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('그룹'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {

            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    group: groups[index],
                    userName: userName, // 사용자명 전달
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
