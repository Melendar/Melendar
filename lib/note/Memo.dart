import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'MemoEditScreen.dart';

class Note extends StatefulWidget {
  const Note({Key? key}) : super(key: key);

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final TextEditingController _userIdController = TextEditingController();

  Future<void> _deleteMemo(String memoId) async {
    final userId = _userIdController.text.trim();
    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('memos')
          .doc(memoId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(), // Firebase 초기화 확인
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Firebase 초기화에 실패했습니다.'));
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        final userId = currentUser?.uid ?? _userIdController.text.trim();

        return Scaffold(
          appBar: AppBar(
            title: const Text('메모'),
            backgroundColor: Colors.white10,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID 입력 (로그인 없이 사용 가능)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: userId.isEmpty
                    ? const Center(child: Text('로그인이 필요하거나 User ID를 입력하세요.'))
                    : StreamBuilder<QuerySnapshot>(
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
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No Memos Yet!', style: TextStyle(fontSize: 24)),
                      );
                    }

                    final memos = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: memos.length,
                      itemBuilder: (context, index) {
                        final memo = memos[index];
                        final memoData = memo.data() as Map<String, dynamic>;
                        final title = memoData['title'] ?? 'Untitled';
                        final content = memoData['content'] ?? '';

                        return ListTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(content),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMemo(memo.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoEditScreen(
                                  memoId: memo.id,
                                  userId: userId, // 입력된 userId 전달
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final userId = _userIdController.text.trim();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoEditScreen(
                    userId: userId, // 입력된 userId 전달
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
