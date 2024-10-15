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
      appBar:
          AppBar(title: const Text
            ('내 정보'), backgroundColor: Colors.green[100]),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: ListView(
          //아래서 만든 위젯을 나열하는 순서
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
    //프로필 이미지
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundImage: _imageFile == null
                ? AssetImage('assets/profile.jfif') as ImageProvider
                : FileImage(File(_imageFile!.path)),
          ),
          // 원 밖의 우측 상단에 아이콘을 배치
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: ((builder) => bottomSheet()));
              },
              child: Icon(
                Icons.add_a_photo_outlined,
                color: secondaryTextColor,
                size: 30, // 크기 조정 가능
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nameTextField() {
    //네임 필드 위젯
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryTextColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: secondaryTextColor,
            width: 2,
          ),
        ),
        prefixIcon: Icon(
          Icons.person,
          color: primaryTextColor,
        ),
        labelText: '이름을 입력하세요',
      ),
    );
  }

  Widget bottomSheet() {
    //프로필 변경 위젯 이미지 변경 연결
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_outlined, size: 50),
            onPressed: () {
              takePhoto(ImageSource.gallery);
            },
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
