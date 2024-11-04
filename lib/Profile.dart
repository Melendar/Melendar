import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistProfile extends StatefulWidget {
  @override
  Profile createState() => Profile();
}

class Profile extends State<RegistProfile> {
  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker();

  static const Color secondaryTextColor = Colors.blue;
  static const Color primaryTextColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보'), backgroundColor: Colors.white10),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: ListView(
          children: <Widget>[
            imageProfile(),
            SizedBox(height: 30),
            nameTextField(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundImage: _imageFile == null
                ? AssetImage('assets/profile.jfif') as ImageProvider
                : FileImage(File(_imageFile!.path)),
          ),
          Positioned(
            bottom: 5, // 프로필 사진과 아이콘이 살짝 겹치도록 위치 조정
            right: 5,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (builder) => bottomSheet(),
                  isScrollControlled: true, // 모달이 스크롤 가능하도록 설정
                );
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // 테두리를 흰색으로 설정해 프로필과 구분
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.add_circle, // `plus_circle` 대신 `add_circle`을 사용 (Dart에서는 `plus_circle`이 없음)
                  color: Colors.white,
                  size: 20,
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: primaryTextColor,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: secondaryTextColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: primaryTextColor,
        ),
        labelText: '이름',
        labelStyle: TextStyle(color: primaryTextColor),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Wrap( // Wrap을 사용하여 내용이 화면을 넘어가지 않도록 조정
        children: [
          Center(
            child: Text(
              '프로필 변경하기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text("앨범에서 사진 선택"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 창 닫기
                takePhoto(ImageSource.gallery); // 갤러리에서 사진 선택
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }
}
