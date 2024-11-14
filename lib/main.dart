import 'package:flutter/material.dart';
import 'package:mobile/firebase_options.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar/calendar.dart';
import 'group/screens/group_list_screen.dart';
import 'note/Memo.dart'; // 메모 화면 import
import 'Profile.dart'; // 프로필 페이지 import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko', ''); // 날짜 형식 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(), // Firebase 초기화
      builder: (context, snapshot) {
        // Firebase 초기화 완료 상태 확인
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'melender',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const GoogleBottomBar(),
          );
        }

        // 초기화가 진행 중일 때 로딩 화면 표시
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
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
    const Calendar(),
    const Note(), // 메모 화면
    GroupListScreen(),
    RegistProfile(), // 프로필 페이지
  ];

  @override
  Widget build(BuildContext context) {
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
