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

  static const Color secondaryTextColor = Colors.blue; // 또는 다른 색상으로 설정
  static const Color primaryTextColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: <Widget>[
            imageProfile(),
            SizedBox(height: 20),
            nameTextField(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }Widget imageProfile() {
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
                Icons.add,  // 연필 아이콘 사용
                color: secondaryTextColor,
                size: 30,  // 크기 조정 가능
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
        labelText: 'Name',
        hintText: 'Input your name',
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
    /*    children: <Widget>[
          Text(
            'Choose Profile photo',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Row(*/
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              TextButton.icon(
                icon: Icon(Icons.photo_library, size: 50),
                onPressed: () {
                 takePhoto(ImageSource.gallery);
                },
                label: Text('Gallery', style: TextStyle(fontSize: 20)),
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
