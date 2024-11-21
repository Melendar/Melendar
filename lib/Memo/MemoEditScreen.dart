import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MemoEditScreen extends StatefulWidget {
  final String? memoId; // memoId를 통해 기존 메모인지 새 메모인지 구분
  final String userId;  // userId를 전달받아 메모 저장
  final String? initialTitle; // 수정 시 기존 제목
  final String? initialContent; // 수정 시 기존 내용

  const MemoEditScreen({
    Key? key,
    required this.userId,
    this.memoId,
    this.initialTitle,
    this.initialContent,
  }) : super(key: key);
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

    if (widget.memoId != null) {
      final doc = await _firestore
          .collection('Users')
          .doc(widget.userId)   // 전달받은 userId 사용
          .collection('Memos')
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

  // 메모 저장
  Future<void> _saveMemo() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (widget.memoId == null) {
      // 새 메모 작성
      await _firestore
          .collection('Users')
          .doc(widget.userId)   // 전달받은 userId 사용
          .collection('Memos')
          .add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // 기존 메모 수정
      await _firestore
          .collection('Users')
          .doc(widget.userId)   // 전달받은 userId 사용
          .collection('Memos')
          .doc(widget.memoId)
          .update({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 작성'),
        actions: [
          TextButton(
            onPressed: _saveMemo,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상
                fontWeight: FontWeight.bold, // 굵은 글씨
                fontSize: 16, // 글씨 크기
              ),
            ),
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
