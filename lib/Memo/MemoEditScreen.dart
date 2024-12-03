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
        backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
        title: const Text('메모 작성'),
        centerTitle: false, // 제목을 왼쪽 정렬
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
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 15.0), // 외부 여백 추가
        padding: const EdgeInsets.all(10.0), // 박스 내부 여백
        decoration: BoxDecoration(
          color: Colors.white, // 박스 배경색
          border: Border.all(color: Colors.black, width: 2), // 테두리 색상 및 두께
          borderRadius: BorderRadius.circular(8.0), // 테두리 둥글게 처리
        ),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요',
                border: InputBorder.none, // 테두리 제거
                enabledBorder: InputBorder.none, // 활성화 상태 테두리 제거
                focusedBorder: InputBorder.none, // 포커스 상태 테두리 제거
                contentPadding: EdgeInsets.symmetric(vertical: 8.0), // 텍스트 여백 설정
              ),
              style: const TextStyle(
                fontSize: 21, // 텍스트 크기
                fontWeight: FontWeight.bold, // 텍스트 굵기 설정
              ), // 텍스트 스타일 설정
            ),
            const Divider(
              color: Colors.grey, // 선 색상
              thickness: 1, // 선 두께
              height: 1, // 선의 높이
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '내용을 입력해주세요',
                border: InputBorder.none, // 테두리 제거
                enabledBorder: InputBorder.none, // 활성화 상태 테두리 제거
                focusedBorder: InputBorder.none, // 포커스 상태 테두리 제거
                contentPadding: EdgeInsets.symmetric(vertical: 8.0), // 텍스트 여백 설정
              ),
              maxLines: null, // 여러 줄 입력 가능
              style: TextStyle(fontSize: 16), // 텍스트 스타일 설정
            ),
          ],
        ),

      ),

    );
  }
}
