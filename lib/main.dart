import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'mypage.dart';  // MyPage를 import

void main() {
  runApp(MyApp());
}
Future<String> callPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.storage,
  ].request();
  if (statuses.values.every((element) => element.isGranted)) {
    return 'success';
  }

  return 'failed';
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();  // 앱이 시작할 때 권한을 확인하고 요청
  }

  // 권한을 확인하고 요청하는 메서드
  Future<void> _checkAndRequestPermission() async {
    var status = await Permission.photos.status;

  /*  if (status.isGranted) {
      // 권한이 이미 허용된 경우
      print('갤러리 접근 권한이 이미 허용되었습니다.');
    } else if (status.isDenied || status.isRestricted || status.isLimited) {
      // 권한이 없거나 제한된 경우 권한 요청
      status = await Permission.photos.request();
      if (status.isGranted) {
        print('갤러리 접근 권한이 허용되었습니다.');
      } else {
        print('갤러리 접근 권한이 거부되었습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // 권한이 영구적으로 거부된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('갤러리 접근 권한을 설정에서 허용해주세요.')),
      );
      openAppSettings();  // 설정 화면으로 이동
    }*/
  }

  // 각 탭에 해당하는 화면
  final List<Widget> _screens = [
    CalendarScreen(),
    MemoScreen(),
    GroupScreen(),
    MyPage(),  // 내 정보 페이지로 MyPage 사용
  ];

  // 탭을 클릭했을 때 호출되는 메서드
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _screens[_currentIndex], // 현재 선택된 화면을 표시
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 4개 이상의 탭을 사용하기 위해 fixed로 설정
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: '메모',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '그룹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}

// 각 화면을 위한 간단한 위젯
class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('캘린더.dart 연동', style: TextStyle(fontSize: 24)),
    );
  }
}

class MemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('메모.dart 연동', style: TextStyle(fontSize: 24)),
    );
  }
}



class GroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('그룹.dart 연동', style: TextStyle(fontSize: 24)),
    );
  }
}
