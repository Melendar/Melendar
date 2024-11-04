import 'package:flutter/material.dart';

class MemoEditScreen extends StatefulWidget {
  const MemoEditScreen({Key? key}) : super(key: key);

  @override
  _MemoEditScreenState createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 화면 아무 곳이나 탭하면 모든 포커스를 해제하고 키보드를 숨김
        _titleFocusNode.unfocus();
        _contentFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('메모 작성', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // 삭제 기능 구현 필요
              },
            ),
            TextButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();

                Navigator.pop(context, {'제목': title, '내용': content});
              },
              child: const Text(
                '완료',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode, // 제목 필드에 포커스 노드 추가
                  decoration: const InputDecoration(
                    hintText: '제목을 입력해주세요',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textInputAction: TextInputAction.next,
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode, // 내용 필드에 포커스 노드 추가
                    decoration: const InputDecoration(
                      hintText: '내용을 입력해주세요',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
