import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class Memo extends StatefulWidget {
  const Memo({Key? key}) : super(key: key);

  @override
  _MemoState createState() => _MemoState();
}

class _MemoState extends State<Memo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  // FirebaseAuth에서 로그인한 사용자 ID를 가져오는 함수
  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      print("로그인되지 않은 사용자입니다.");
    }
  }

  // Firestore에서 메모 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> fetchMemosByUserId(String userId) async {
    if (userId.isEmpty) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Memos')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final date =
        timestamp != null ? timestamp.toDate().toString() : 'No Date';

        return {
          'memoId': doc.id,
          'title': data['title'] ?? '제목 없음',
          'content': data['content'] ?? '내용 없음',
          'date': date,
        };
      }).toList();
    } catch (e) {
      print('Error fetching memos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 정보가 없으면 로딩 화면 표시
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 관리'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMemosByUserId(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                '저장된 메모가 없습니다!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final memos = snapshot.data!;

          return ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              final memoId = memo['memoId'];
              final title = memo['title'];
              final content = memo['content'];
              final date = memo['date'];

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.black45),
                    onPressed: () async {
                      await _firestore
                          .collection('Users')
                          .doc(_userId)
                          .collection('Memos')
                          .doc(memoId)
                          .delete();
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
