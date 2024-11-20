import 'package:flutter/material.dart';
import 'package:mobile/firebase_options.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar/calendar.dart';
import 'group/screens/group_list_screen.dart';
import 'note/Memo.dart'; // 메모 화면 import
import 'Profile.dart'; // 프로필 페이지 import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko', ''); // 날짜 형식 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Memo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInPage(),
    );
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
);

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  Future<void> _signIn(BuildContext context) async {
  try {
    print("Google 로그인 시작");

    // Google 로그아웃 시도
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print("로그인 취소됨");
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? currentUser = userCredential.user;

    if (currentUser != null) {
      print("로그인 성공: UID - ${currentUser.uid}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoogleBottomBar()),
      );
    } else {
      print("로그인 실패: 사용자 정보가 없습니다.");
    }
  } catch (e) {
    print("Google 로그인 오류: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFE1F5FE),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MELENDAR',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signIn(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
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
