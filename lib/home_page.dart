import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'user_provider.dart';
import 'calendar/calendar.dart';
import 'group/screens/group_list_screen.dart';
import 'note/Memo.dart';
import 'Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 각 네비게이션 탭에 연결된 페이지
  final List<Widget> _pages = [
    const Calendar(),
    const Note(), // 메모 화면
    GroupListScreen(),
    RegistProfile(), // 프로필 페이지
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }
}

// SalomonBottomBar 아이템 정의
final _navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.calendar_today_outlined),
    title: const Text("캘린더"),
    selectedColor: Colors.purple,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.note),
    title: const Text("메모"),
    selectedColor: Colors.blueAccent,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.group_outlined),
    title: const Text("그룹"),
    selectedColor: Colors.orange,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("내 정보"),
    selectedColor: Colors.blueGrey,
  ),
];
