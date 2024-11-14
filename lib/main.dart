import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'service/user_service.dart';
import 'service/memo_service.dart';
import 'service/group_service.dart';
import 'service/event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase 초기화 완료");
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
        MaterialPageRoute(builder: (context) => HomePage()),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  String _newNickname = '';
  String _memoTitle = '';
  String _memoContent = '';
  String _updateMemoId = '';
  String _updateMemoTitle = '';
  String _updateMemoContent = '';
  String _deleteMemoId = '';
  String _searchUserId = '';
  String _searchedUserNickname = '';
  String _searchedUserProfileImage = '';
  List<Map<String, dynamic>> _searchedMemos = [];

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

  Future<void> _createMemo() async {
    print("메모 생성 시작");
    await createMemo(_user!.uid, _memoTitle, _memoContent);
    print("메모 생성 완료");
  }

  Future<void> _updateMemo() async {
    print("메모 수정 시작: ID - $_updateMemoId");
    await updateMemo(
        _user!.uid, _updateMemoId, _updateMemoTitle, _updateMemoContent);
    print("메모 수정 완료");
  }

  Future<void> _deleteMemo() async {
    print("메모 삭제 시작: ID - $_deleteMemoId");
    await deleteMemo(_user!.uid, _deleteMemoId);
    print("메모 삭제 완료");
  }

  Future<void> _fetchMemosByUserId() async {
    print("User의 모든 메모 가져오기 시작: User ID - $_searchUserId");
    await fetchMemosByUserId(_searchUserId, (memos) {
      setState(() {
        _searchedMemos = memos;
        print("메모 가져오기 완료: ${_searchedMemos.length}개 메모 발견");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Memo App'),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      '$_profileImageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                    ),
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text('닉네임: $_nickname'),
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
                    child: Text('프로필 이미지 변경'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '메모 제목'),
                    onChanged: (value) => _memoTitle = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '메모 내용'),
                    onChanged: (value) => _memoContent = value,
                  ),
                  ElevatedButton(
                    onPressed: _createMemo,
                    child: const Text('메모 생성'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '수정할 메모 ID'),
                    onChanged: (value) => _updateMemoId = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '새 메모 제목'),
                    onChanged: (value) => _updateMemoTitle = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '새 메모 내용'),
                    onChanged: (value) => _updateMemoContent = value,
                  ),
                  ElevatedButton(
                    onPressed: _updateMemo,
                    child: const Text('메모 수정'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '삭제할 메모 ID'),
                    onChanged: (value) => _deleteMemoId = value,
                  ),
                  ElevatedButton(
                    onPressed: _deleteMemo,
                    child: const Text('메모 삭제'),
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: '검색할 User ID 입력'),
                    onChanged: (value) => _searchUserId = value,
                  ),
                  ElevatedButton(
                    onPressed: _fetchUserById,
                    child: const Text('User 정보 가져오기'),
                  ),
                  if (_searchedUserNickname.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        '$_searchedUserProfileImage?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                      ),
                      radius: 40,
                    ),
                    Text('닉네임: $_searchedUserNickname'),
                  ],
                  ElevatedButton(
                    onPressed: _fetchMemosByUserId,
                    child: const Text('User의 모든 메모 가져오기'),
                  ),
                  if (_searchedMemos.isNotEmpty)
                    Column(
                      children: _searchedMemos.map((memo) {
                        return Card(
                          child: ListTile(
                            title: Text(memo['title']),
                            subtitle: Text(memo['content']),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(memo['date']),
                                Text(
                                  'ID: ${memo['memoId']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (_searchedMemos.isEmpty && _searchUserId.isNotEmpty)
                    const Text('메모가 없습니다.'),
                  const SizedBox(height: 20),
                  // 로그아웃 버튼 추가
                  ElevatedButton(
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
                ],
              ),
            ),
    );
  }
}
