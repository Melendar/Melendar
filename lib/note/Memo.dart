import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'MemoEditScreen.dart';

class Note extends StatefulWidget {
  const Note({Key? key}) : super(key: key);

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final TextEditingController _userIdController = TextEditingController();

  /// 스낵바 메시지 표시 함수
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 메모 삭제 함수
  Future<void> _deleteMemo(String memoId) async {
    final userId = _getUserId();
    if (userId.isEmpty) {
      _showMessage('User ID를 입력해주세요.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('memos')
          .doc(memoId)
          .delete();

      _showMessage('메모가 성공적으로 삭제되었습니다.');
    } catch (e) {
      _showMessage('메모 삭제 실패: $e');
      print('Error deleting memo: $e');
    }
  }

  /// 유저 ID 가져오기 함수
  String _getUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? _userIdController.text.trim();
  }

  /// 메모 리스트 빌드 함수
  Widget _buildMemoList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('memos')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('오류가 발생했습니다: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('저장된 메모가 없습니다!', style: TextStyle(fontSize: 18)),
          );
        }

        final memos = snapshot.data!.docs;

        return ListView.builder(
          itemCount: memos.length,
          itemBuilder: (context, index) {
            final memo = memos[index];
            final memoId = memo.id;
            final memoData = memo.data() as Map<String, dynamic>;
            final title = memoData['title'] ?? '제목 없음';
            final content = memoData['content'] ?? '';
            final timestamp = (memoData['timestamp'] as Timestamp?)?.toDate();
            final date = timestamp != null
                ? '${timestamp.year}-${timestamp.month}-${timestamp.day}'
                : '날짜 없음';

            return ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$content\n$date', maxLines: 2, overflow: TextOverflow.ellipsis),
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteMemo(memoId),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoEditScreen(
                      memoId: memoId,
                      userId: userId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = _getUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 관리'),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _userIdController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (currentUser == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          Expanded(
            child: userId.isEmpty
                ? const Center(
              child: Text(
                '로그인하거나 User ID를 입력하세요.',
                style: TextStyle(fontSize: 18),
              ),
            )
                : _buildMemoList(userId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final userId = _getUserId();
          if (userId.isEmpty) {
            _showMessage('메모 추가를 위해 User ID가 필요합니다.');
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoEditScreen(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
