import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'service/user_service.dart';
import 'service/memo_service.dart';
import 'service/event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Memo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}

// 상태 관리를 위한 클래스
class _HomePageState extends State<HomePage> {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  String _newNickname = '';
  String _newProfileImageUrl = '';
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

  // 구글 로그인 자동 실행
  @override
  void initState() {
    super.initState();
    _signInWithGoogle();
  }

  // 구글 로그인
  Future<void> _signInWithGoogle() async {
    await signInWithGoogle();
    setState(() => _user = FirebaseAuth.instance.currentUser);
    await _handleUserInFirestore();
  }

  Future<void> _handleUserInFirestore() async {
    await handleUserInFirestore((nickname, profileImageUrl) {
      setState(() {
        _nickname = nickname;
        _profileImageUrl = profileImageUrl;
      });
    });
  }

  Future<void> _fetchUserById() async {
    await fetchUserById(_searchUserId, (nickname, profileImageUrl) {
      setState(() {
        _searchedUserNickname = nickname;
        _searchedUserProfileImage = profileImageUrl;
      });
    });
  }

  Future<void> _updateNickname() async {
    await updateNickname(_newNickname, (nickname) {
      setState(() => _nickname = nickname);
    });
  }

  Future<void> _updateProfileImage() async {
    try {
      print("프로필 이미지 변경 시작");

      // Firebase Storage로 이미지 업로드 및 Firestore 업데이트
      await updateProfileImage((downloadUrl) {
        if (downloadUrl.isNotEmpty) {
          print("Firestore에 업데이트된 프로필 이미지 URL: $downloadUrl");

          // UI 업데이트
          setState(() {
            _profileImageUrl = downloadUrl;
          });

          print("UI 업데이트 완료");
        } else {
          print("다운로드 URL이 비어있습니다.");
        }
      });
    } catch (e) {
      print("프로필 이미지 업데이트 오류: $e");
    }
  }

  Future<void> _createMemo() async {
    await createMemo(_user!.uid, _memoTitle, _memoContent);
  }

  Future<void> _updateMemo() async {
    await updateMemo(
        _user!.uid, _updateMemoId, _updateMemoTitle, _updateMemoContent);
  }

  Future<void> _deleteMemo() async {
    await deleteMemo(_user!.uid, _deleteMemoId);
  }

  Future<void> _fetchMemosByUserId() async {
    await fetchMemosByUserId(_searchUserId, (memos) {
      setState(() => _searchedMemos = memos);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Memo App'),
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_profileImageUrl),
                    radius: 40,
                  ),
                  SizedBox(height: 16),
                  Text('닉네임: $_nickname'),
                  TextField(
                    decoration: InputDecoration(labelText: '새 닉네임'),
                    onChanged: (value) => _newNickname = value,
                  ),
                  ElevatedButton(
                    onPressed: _updateNickname,
                    child: Text('닉네임 변경'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '새 프로필 이미지 URL'),
                    onChanged: (value) => _newProfileImageUrl = value,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      print("프로필 이미지 변경 버튼 클릭됨");

                      // 이미지 업로드 및 Firestore 업데이트
                      await updateProfileImage((downloadUrl) {
                        if (downloadUrl.isNotEmpty) {
                          // UI 업데이트
                          setState(() {
                            _profileImageUrl = downloadUrl;
                          });
                          print("UI 업데이트 완료: $_profileImageUrl");
                        } else {
                          print("이미지 업로드 실패 또는 다운로드 URL이 비어있음");
                        }
                      });
                    },
                    child: Text('프로필 이미지 변경'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '메모 제목'),
                    onChanged: (value) => _memoTitle = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '메모 내용'),
                    onChanged: (value) => _memoContent = value,
                  ),
                  ElevatedButton(
                    onPressed: _createMemo,
                    child: Text('메모 생성'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '수정할 메모 ID'),
                    onChanged: (value) => _updateMemoId = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '새 메모 제목'),
                    onChanged: (value) => _updateMemoTitle = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '새 메모 내용'),
                    onChanged: (value) => _updateMemoContent = value,
                  ),
                  ElevatedButton(
                    onPressed: _updateMemo,
                    child: Text('메모 수정'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '삭제할 메모 ID'),
                    onChanged: (value) => _deleteMemoId = value,
                  ),
                  ElevatedButton(
                    onPressed: _deleteMemo,
                    child: Text('메모 삭제'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '검색할 User ID 입력'),
                    onChanged: (value) => _searchUserId = value,
                  ),
                  ElevatedButton(
                    onPressed: _fetchUserById,
                    child: Text('User 정보 가져오기'),
                  ),
                  if (_searchedUserNickname.isNotEmpty) ...[
                    SizedBox(height: 16),
                    CircleAvatar(
                      backgroundImage: NetworkImage(_profileImageUrl),
                      radius: 40,
                    ),
                    Text('닉네임: $_searchedUserNickname'),
                  ],
                  ElevatedButton(
                    onPressed: _fetchMemosByUserId,
                    child: Text('User의 모든 메모 가져오기'),
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
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (_searchedMemos.isEmpty && _searchUserId.isNotEmpty)
                    Text('메모가 없습니다.'),
                ],
              ),
            ),
    );
  }
}
