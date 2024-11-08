import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _memos = [];
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

  @override
  void initState() {
    super.initState();
    _signInWithGoogle();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);
      setState(() => _user = userCredential.user);
      await _handleUserInFirestore();
      await _fetchMemos();
    } catch (e) {
      print("Google 로그인 오류: $e");
    }
  }

  Future<void> _handleUserInFirestore() async {
    if (_user == null) return;

    final userRef = _firestore.collection('Users').doc(_user!.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'userId': _user!.uid,
        'nickname': _user!.displayName ?? 'Anonymous',
        'profileImage': _user!.photoURL ?? '',
      });
    }

    _nickname = _user!.displayName ?? 'Anonymous';
    _profileImageUrl = _user!.photoURL ?? '';
    setState(() {});
  }

  // 닉네임 업데이트
  Future<void> _updateNickname() async {
    if (_user == null || _newNickname.isEmpty) return;
    await _firestore.collection('Users').doc(_user!.uid).update({
      'nickname': _newNickname,
    });
    setState(() {
      _nickname = _newNickname;
    });
  }

  // 이미지 업데이트
  Future<void> _updateProfileImage() async {
    if (_user == null || _newProfileImageUrl.isEmpty) return;
    await _firestore.collection('Users').doc(_user!.uid).update({
      'profileImage': _newProfileImageUrl,
    });
    setState(() {
      _profileImageUrl = _newProfileImageUrl;
    });
  }

  Future<void> _fetchMemos() async {
    if (_user == null) return;
    final querySnapshot = await _firestore
        .collection('Memos')
        .where('user_id', isEqualTo: _user!.uid)
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _memos = querySnapshot.docs.map((doc) {
        return {
          'memoId': doc.id,
          'content': doc['content'],
          'title': doc['title'],
          'date': doc['date'],
        };
      }).toList();
    });
  }

  // 메모 생성
  Future<void> _createMemo() async {
    if (_user == null || _memoTitle.isEmpty || _memoContent.isEmpty) return;
    await _firestore.collection('Memos').add({
      'user_id': _user!.uid,
      'date': FieldValue.serverTimestamp(),
      'title': _memoTitle,
      'content': _memoContent,
    });
    await _fetchMemos();
  }

  // 메모 업데이트
  Future<void> _updateMemo() async {
    if (_updateMemoId.isEmpty ||
        _updateMemoTitle.isEmpty ||
        _updateMemoContent.isEmpty) return;
    await _firestore.collection('Memos').doc(_updateMemoId).update({
      'title': _updateMemoTitle,
      'content': _updateMemoContent,
    });
    await _fetchMemos();
  }

  // 메모 삭제
  Future<void> _deleteMemo() async {
    if (_deleteMemoId.isEmpty) return;
    await _firestore.collection('Memos').doc(_deleteMemoId).delete();
    await _fetchMemos();
  }

  // userId 값으로 사용자 정보 가져오기
  Future<void> _fetchUserById() async {
    if (_searchUserId.isEmpty) return;
    final userDoc =
        await _firestore.collection('Users').doc(_searchUserId).get();

    if (userDoc.exists) {
      setState(() {
        _searchedUserNickname = userDoc['nickname'] ?? 'Anonymous';
        _searchedUserProfileImage = userDoc['profileImage'] ?? '';
      });
      print("사용자 데이터를 가져왔습니다: $_searchedUserNickname");
    } else {
      print("사용자를 찾을 수 없습니다.");
    }
  }

  // userId 값으로 메모 정보 가져오기
  Future<void> _fetchMemosByUserId() async {
    if (_searchUserId.isEmpty) return;
    final querySnapshot = await _firestore
        .collection('Memos')
        .where('user_id', isEqualTo: _searchUserId)
        .orderBy('date', descending: true)
        .get();

    setState(() {
    _searchedMemos = querySnapshot.docs.map((doc) {
      final timestamp = doc['date'] as Timestamp?;
      final date = timestamp != null ? timestamp.toDate().toString() : 'No Date';
      return {
        'memoId': doc.id,
        'content': doc['content'],
        'title': doc['title'],
        'date': date,
      };
    }).toList();
  });
    print("메모 데이터를 가져왔습니다: ${_searchedMemos.length}개");
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
                    onPressed: _updateProfileImage,
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
                    backgroundImage:
                        NetworkImage(_searchedUserProfileImage ?? ''),
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
                          trailing: Text(memo['date']),
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
