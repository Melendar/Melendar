import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_provider.dart';
import '../tabbar.dart';
import '../service/group_service.dart';
//mport 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:custom_signin_buttons/custom_signin_buttons.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Future<void> _signIn(BuildContext context) async {
    try {
      print("Google 로그인 시작");

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("로그인 취소됨");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? currentUser = userCredential.user;

      if (currentUser != null) {
        print("로그인 성공: UID - ${currentUser.uid}");

        final groupService = GroupService();
        // 처음 들어오는 유저면 개인그룹 생성. isNewUser는 파베 제공값. 조건문 : 좌측 조건이 null 이거나 false면 false 반환
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await groupService.createPersonalGroup(currentUser.uid);
        }
        // 그룹 정보 가져와서 저장
        List<Map<String, dynamic>> userGroups = await groupService.getGroupsByUser(currentUser.uid);
        Provider.of<UserProvider>(context, listen: false).setGroups(userGroups);
        
      } else {
        print("로그인 실패: 사용자 정보가 없습니다.");
      }
    } catch (e) {
      print("Google 로그인 오류: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                User? user = snapshot.data;
                if (user == null) {
                  return Scaffold(
                    body: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xEBF6FB),
                            Color(0xFFFFFFFF),
                            Color(0x80FFFFFF),

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
                          //const SizedBox(height: 20),

                          SignInButton(
                            button: Button.GoogleBlack,
                            borderRadius: 15,

                            mini: false,
                            onPressed: () => _signIn(context),
                            splashColor: Colors.white,
                            small: false,
                            // textColor: Colors.blue,
                            showText: true,
                            textSize: 15,
                            width: 320,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                Provider.of<UserProvider>(context, listen: false).setUser(user);
                return HomePage();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}