import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MemoEditScreen extends StatefulWidget {
  final String? memoId; // memoId를 전달받아 기존 메모인지 새 메모인지 구분

  const MemoEditScreen({Key? key, this.memoId}) : super(key: key);

  @override
  _MemoEditScreenState createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.memoId != null) {
      _loadMemo();
    }
  }

  // 메모 불러오기 (수정 시)
  Future<void> _loadMemo() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.memoId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('memos')
          .doc(widget.memoId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data['title'] ?? '';
        _contentController.text = data['content'] ?? '';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMemo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.memoId == null) {
        // 새 메모 작성
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memos')
            .add({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // 기존 메모 수정
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memos')
            .doc(widget.memoId)
            .update({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 작성'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMemo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '내용을 입력해주세요',
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
