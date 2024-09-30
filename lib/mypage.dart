import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? _image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                // 프로필 사진
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  backgroundColor: Colors.grey[200],
                  child: _image == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                      : null,
                ),
                // + 버튼을 오른쪽 하단에 위치시키기
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 프로필 사진과 텍스트 사이의 간격
            // 사용자 이름 또는 정보
            Text(
              '홍길동',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
