import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'note/Note.dart';  // 메모 화면 import
import 'Profile.dart';  // 프로필 페이지 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GoogleBottomBar(),
    );
  }
}

class GoogleBottomBar extends StatefulWidget {
  const GoogleBottomBar({Key? key}) : super(key: key);

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;

  // 각 네비게이션 탭에 연결된 페이지
  final List<Widget> _pages = [
    const Center(child: Text('ㄴㄴ Screen', style: TextStyle(fontSize: 24))),
    const Note(),        // 메모 화면
    const Center(child: Text('Search Screen', style: TextStyle(fontSize: 24))),
    RegistProfile(),     // 프로필 페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Bottom Bar'),
        backgroundColor: _navBarItems[_selectedIndex].selectedColor,
      ),
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
    icon: const Icon(Icons.home),
    title: const Text("Home"),
    selectedColor: Colors.purple,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.note),
    title: const Text("Memo"),
    selectedColor: Colors.pink,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.search),
    title: const Text("Search"),
    selectedColor: Colors.orange,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("Profile"),
    selectedColor: Colors.teal,
  ),
];
