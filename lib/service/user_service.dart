import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
);
User? _user;

// 구글 로그인
Future<void> signInWithGoogle() async {
  try {
    print("Google 로그인 시작");

    if (Platform.isAndroid || Platform.isIOS) {
      // Android 및 iOS용 Google 로그인
      print("모바일 플랫폼에서 Google 로그인 시도");

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Google 로그인 취소됨");
        return;
      }

      print("Google 사용자 정보 요청 중");
      print("사용자 이메일: ${googleUser.email}");
      print("사용자 이름: ${googleUser.displayName}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Access Token: ${googleAuth.accessToken}");
      print("ID Token: ${googleAuth.idToken}");

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Firebase 인증 자격 증명 생성 완료");

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        print("Google 로그인 성공: ${_user?.displayName}");
        print("사용자 UID: ${_user?.uid}");
        print("사용자 이메일: ${_user?.email}");
        print("사용자 프로필 사진 URL: ${_user?.photoURL}");
      } else {
        print("Google 로그인 실패: 사용자 정보가 없습니다.");
      }
    } else {
      // 웹용 Google 로그인
      print("웹 플랫폼에서 Google 로그인 시도");

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      _user = userCredential.user;

      if (_user != null) {
        print("Google 로그인 성공: ${_user?.displayName}");
        print("사용자 UID: ${_user?.uid}");
        print("사용자 이메일: ${_user?.email}");
        print("사용자 프로필 사진 URL: ${_user?.photoURL}");
      } else {
        print("Google 로그인 실패: 사용자 정보가 없습니다.");
      }
    }
  } catch (e) {
    print("Google 로그인 오류: $e");
  }
}

// 사용자 정보 업로드
Future<void> handleUserInFirestore(Function callback) async {
  try {
    // 현재 로그인한 사용자 가져오기
    _user = _auth.currentUser;

    if (_user == null) {
      print("Firestore: 로그인된 사용자 정보가 없습니다.");
      return;
    }

    print("Firestore: 사용자 UID - ${_user!.uid}");

    // Firestore에서 사용자 문서 참조
    final userRef = _firestore.collection('Users').doc(_user!.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      // Firestore에 사용자 정보가 이미 존재하는 경우
      final nickname = userDoc.data()?['nickname'] ?? 'Anonymous';
      final profileImage = userDoc.data()?['profileImage'] ?? '';

      print("Firestore: 기존 사용자 정보 조회 성공 - 닉네임: $nickname, 프로필 이미지: $profileImage");

      // 화면 업데이트 콜백 호출
      callback(nickname, profileImage);
    } else {
      // Firestore에 사용자 정보가 없는 경우, Google 계정 정보로 새로운 사용자 생성
      final googleNickname = _user!.displayName ?? 'Anonymous';
      final googleProfileImage = _user!.photoURL ?? '';

      print("Firestore: 사용자 정보 없음, 새 사용자 생성 중 - 닉네임: $googleNickname, 프로필 이미지: $googleProfileImage");

      // Firestore에 새로운 사용자 정보 저장
      await userRef.set({
        'nickname': googleNickname,
        'profileImage': googleProfileImage,
      });

      // 새로운 사용자 정보로 화면 업데이트 콜백 호출
      callback(googleNickname, googleProfileImage);
    }
  } catch (e) {
    print("handleUserInFirestore 오류: $e");
  }
}


// Android의 ContentResolver를 사용해 URI에서 바이트 데이터를 읽어오기
Future<ByteData?> getUriByteData(String uri) async {
  try {
    print("ContentResolver에서 데이터를 읽어옵니다.");

    // URI를 UTF-8로 인코딩하여 Uint8List로 변환
    Uint8List uint8List = Uint8List.fromList(utf8.encode(uri));

    // Uint8List를 ByteData로 변환
    ByteData byteData = uint8List.buffer.asByteData();

    return byteData;
  } catch (e) {
    print("ContentResolver에서 데이터를 읽어오는 중 오류 발생: $e");
    return null;
  }
}

Future<Uint8List?> _getBytesFromUri(String uri) async {
  try {
    print("ContentResolver에서 데이터를 읽어옵니다.");
    // 파일 경로로부터 데이터를 읽어옵니다.
    final Uint8List byteData = await File(uri).readAsBytes();
    print("데이터 읽기 완료: ${byteData.length} bytes");
    return byteData;
  } catch (e) {
    print("ContentResolver에서 데이터를 읽어오는 중 오류 발생: $e");
    return null;
  }
}

// userId 값으로 사용자 정보 가져오기
Future<Map<String, String>> fetchUserById(String userId) async {
  if (userId.isEmpty) return {};

  try {
    final userDoc = await _firestore.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      final nickname = userDoc['nickname'] ?? 'Anonymous';
      final profileImageUrl = userDoc['profileImage'] ?? ''; // 디코딩 제거
      print("Firestore에서 가져온 닉네임: $nickname, 프로필 이미지 URL: $profileImageUrl");
      return {
        'nickname': nickname,
        'profileImage': profileImageUrl,
      };
    } else {
      return {};
    }
  } catch (e) {
    print("fetchUserById 오류: $e");
    return {};
  }
}

// 사용자 닉네임 업데이트
Future<void> updateNickname(String newNickname, Function callback) async {
  if (_user == null || newNickname.isEmpty) return;
  await _firestore.collection('Users').doc(_user!.uid).update({
    'nickname': newNickname,
  });
  callback(newNickname);
}

// 사용자 프로필 이미지 업데이트
Future<void> updateProfileImage(Function callback) async {
  try {
    print("프로필 이미지 업데이트 시작");

    // 1. 파일 선택
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      print("이미지 선택 취소됨");
      callback('');
      return;
    }

    String fileName = result.files.first.name;
    Uint8List? fileBytes;

    // 2. URI에서 직접 파일 읽기 시도
    final uri = result.files.first.path;
    if (uri != null) {
      try {
        print("파일 바이트가 null입니다. URI를 통해 이미지를 읽어옵니다.");
        // Android의 ContentResolver를 사용해 파일 읽기
        final Uint8List? byteData = await _getBytesFromUri(uri);
        if (byteData != null) {
          fileBytes = byteData.buffer.asUint8List();
        } else {
          print("ContentResolver에서 파일 데이터를 가져오지 못했습니다.");
          callback('');
          return;
        }
      } catch (e) {
        print("이미지 읽기 실패: $e");
        callback('');
        return;
      }
    } else {
      print("URI가 null입니다. 업로드를 중단합니다.");
      callback('');
      return;
    }

    if (fileBytes == null) {
      print("파일 바이트가 여전히 null입니다. 업로드를 중단합니다.");
      callback('');
      return;
    }

    print("이미지 선택 완료: $fileName");

    // 3. Firebase Storage 참조 생성
    final storageRef = FirebaseStorage.instance.ref('profile_images/$fileName');

    // 4. Firebase Storage에 파일 업로드 시작
    final uploadTask = storageRef.putData(fileBytes);
    print("Firebase Storage 업로드 시작");

    // 업로드 진행 상태 출력
    uploadTask.snapshotEvents.listen((event) {
      final progress = (event.bytesTransferred / event.totalBytes) * 100;
      print("업로드 진행 중: ${progress.toStringAsFixed(2)}%");
    });

    // 5. 업로드 완료 및 다운로드 URL 가져오기
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print("업로드 완료: $downloadUrl");

    // 6. Firestore의 profile_image 필드 업데이트
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'profileImage': downloadUrl,
      });
      print("Firestore 업데이트 완료");
    }

    // 7. 콜백 호출
    callback(downloadUrl);
  } catch (e) {
    print("이미지 업로드 및 Firestore 업데이트 오류: $e");
    callback('');
  }
}
