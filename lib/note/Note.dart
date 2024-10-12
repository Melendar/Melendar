import 'package:flutter/material.dart';
import 'MemoEditScreen.dart';  // 메모 편집 화면 import

class Note extends StatelessWidget {
  const Note({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo List'),
      ),
      body: const Center(
        child: Text('No Memos Yet!', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 메모 편집 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MemoEditScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
