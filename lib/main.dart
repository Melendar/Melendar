import 'package:flutter/material.dart';
import 'package:mobile/service/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'user_manage/user_provider.dart';
import 'user_manage/sign_in_page.dart';

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