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
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_page.dart';

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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInPage(),
    );
  }
}