import 'package:flutter/material.dart';
import 'dart:io';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? _image;
  bool _isEditingName = false;
  String _name = '홍길동';
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( // SafeArea를 추가하여 시스템 UI와 겹치지 않도록 설정
      child: Scaffold(
        appBar: AppBar(
          title: Text('내 정보'),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    backgroundColor: Colors.grey[200],
                    child: _image == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        // 이미지 선택을 위한 기능 추가 가능
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isEditingName
                    ? Container(
                  width: 200,
                  child: TextField(
                    controller: _nameController,
                    onSubmitted: (newName) {
                      setState(() {
                        _name = newName;
                        _isEditingName = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '이름을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
                    : Text(
                  _name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditingName = true;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/*
void main() {
  runApp(MaterialApp(
    home: MyPage(),
  ));
}*/
