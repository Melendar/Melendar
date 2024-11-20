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
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko', ''); // 날짜 형식 초기화
  // Provider 사용
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
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
            debugShowCheckedModeBanner: false,
            title: 'melender',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;
                  if (user == null) {
                    return LoginPage();
                  }
                  Provider.of<UserProvider>(context, listen: false)
                      .setUser(user);
                  return HomePage();
                }
                //초기화중일때 로딩화면 표시
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
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
