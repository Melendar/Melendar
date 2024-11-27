import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Clipboard 사용
import '../service/user_service.dart';
import 'sign_in_page.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

class RegistProfile extends StatefulWidget {
  @override
  Profile createState() => Profile();
}

class Profile extends State<RegistProfile> {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  String _newNickname = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();@override
    void initState() {
      super.initState();
      _initializeUser();
    }
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
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();

      Provider.of<UserProvider>(context, listen: false).clearUser();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } catch (e) {
      print("로그아웃 오류: $e");
    }
  }

  Future<void> _handleUserInFirestore() async {
    await handleUserInFirestore((nickname, profileImageUrl) {
      setState(() {
        _nickname = nickname;
        _profileImageUrl = profileImageUrl;
      });
    });
  }

  Future<void> _updateNickname() async {
    if (_newNickname.isNotEmpty) {
      await updateNickname(_newNickname, (nickname) {
        setState(() {
          _nickname = nickname;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("새 닉네임을 입력하세요.")),
      );
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      await updateProfileImage((downloadUrl) {
        if (downloadUrl.isNotEmpty) {
          setState(() {
            _profileImageUrl = downloadUrl;
          });
        }
      });
    } catch (e) {
      print("프로필 이미지 업데이트 오류: $e");
    }
  }

  void _copyUserIdToClipboard(String userId) {
    Clipboard.setData(ClipboardData(text: userId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("유저 ID가 클립보드에 복사되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
      ),
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              '$_profileImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                            ),
                            radius: 60,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _updateProfileImage,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '닉네임: $_nickname',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("닉네임 변경"),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                          hintText: "새 닉네임을 입력하세요"),
                                      onChanged: (value) => _newNickname = value,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("취소"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _updateNickname();
                                        },
                                        child: const Text("확인"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: "닉네임 변경",
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ID: ${_user?.uid ?? "알 수 없음"}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              if (_user?.uid != null) {
                                _copyUserIdToClipboard(_user!.uid);
                              }
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: "ID 복사",
                          ),
                        ],
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
