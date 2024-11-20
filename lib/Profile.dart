import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service/user_service.dart';
import './sign_in_page.dart';

class RegistProfile extends StatefulWidget {
  @override
  Profile createState() => Profile();
}

class Profile extends State<RegistProfile> {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  String _newNickname = '';
  String _searchUserId = '';
  String _searchedUserNickname = '';
  String _searchedUserProfileImage = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
      await _handleUserInFirestore();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // FirebaseAuth 로그아웃
      await FirebaseAuth.instance.signOut();

      // Google 계정 로그아웃 (세션 해제)
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();

      print("로그아웃 완료");

      // 로그아웃 후 SignInPage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } catch (e) {
      print("로그아웃 오류: $e");
    }
  }

  Future<void> _handleUserInFirestore() async {
    print("Firestore에서 사용자 정보 처리 시작");
    await handleUserInFirestore((nickname, profileImageUrl) {
      setState(() {
        _nickname = nickname;
        _profileImageUrl = profileImageUrl;
        print(
            "Firestore 사용자 정보 업데이트 완료: 닉네임 - $_nickname, 프로필 이미지 - $_profileImageUrl");
      });
    });
  }

  Future<void> _fetchUserById() async {
    try {
      print("사용자 정보 가져오기 시작: User ID - $_searchUserId");
      final userData = await fetchUserById(_searchUserId);
      final nickname = userData['nickname'] ?? 'Anonymous';
      final profileImageUrl = userData['profileImage'] ?? '';

      setState(() {
        _searchedUserNickname = nickname;
        _searchedUserProfileImage = profileImageUrl;
        print(
            "사용자 정보 가져오기 완료: 닉네임 - $_searchedUserNickname, 프로필 이미지 - $_searchedUserProfileImage");
      });
    } catch (e) {
      print("사용자 정보 가져오기 오류: $e");
    }
  }

  Future<void> _updateNickname() async {
    print("닉네임 업데이트 시작: $_newNickname");
    await updateNickname(_newNickname, (nickname) {
      setState(() {
        _nickname = nickname;
        print("닉네임 업데이트 완료: $_nickname");
      });
    });
  }

  Future<void> _updateProfileImage() async {
    try {
      print("프로필 이미지 업데이트 시작");
      await updateProfileImage((downloadUrl) {
        if (downloadUrl.isNotEmpty) {
          setState(() {
            _profileImageUrl = downloadUrl;
          });
          print("프로필 이미지 업데이트 완료: $_profileImageUrl");
        } else {
          print("이미지 업로드 실패 또는 다운로드 URL이 비어있음");
        }
      });
    } catch (e) {
      print("프로필 이미지 업데이트 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 위젯 간의 여백 분배
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // 버튼이 화면 폭을 채우도록 설정
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          '$_profileImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                        ),
                        radius: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '닉네임: $_nickname',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_user?.uid ?? "알 수 없음"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey, // 회색 텍스트
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: '새 닉네임'),
                        onChanged: (value) => _newNickname = value,
                      ),
                      ElevatedButton(
                        onPressed: _updateNickname,
                        child: const Text('닉네임 변경'),
                      ),
                      ElevatedButton(
                        onPressed: _updateProfileImage,
                        child: const Text('프로필 이미지 변경'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Log out',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
