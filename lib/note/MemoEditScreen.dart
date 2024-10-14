import 'package:flutter/material.dart';

class MemoEditScreen extends StatefulWidget {
  const MemoEditScreen({Key? key}) : super(key: key);

  @override
  _MemoEditScreenState createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final TextEditingController _memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모'),
          backgroundColor: Colors.green[100],
        actions: [
          TextButton(
            onPressed: () {
              // 제목과 내용을 구분하여 저장
              final text = _memoController.text.trim();
              final title = text.split('\n').first; // 첫 줄을 제목으로
              final content = text.replaceFirst('$title\n', ''); // 나머지를 내용으로

              // 이전 화면으로 데이터 전달
              Navigator.pop(context, {'제목': title, '내용': content});
            },
            child: const Text(
              '완료',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _memoController,
          decoration: InputDecoration(
            hintText: '제목을 입력해주세요\n\n내용을 입력해주세요', // 한국어 힌트
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
            ),
            contentPadding: const EdgeInsets.all(16.0), // 내부 패딩
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 18), // 글자 크기 조정
          keyboardType: TextInputType.multiline, // 여러 줄 입력 가능
          maxLines: null, // 줄바꿈 가능
          expands: true, // 남은 공간 채우기
          textAlignVertical: TextAlignVertical.top, // 텍스트를 상단에 정렬
        ),
      ),
    );
  }
}
