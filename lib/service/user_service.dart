import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? _user;

// 구글 로그인
Future<void> signInWithGoogle() async {
  try {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final UserCredential userCredential =
        await _auth.signInWithPopup(googleProvider);
    _user = userCredential.user;
  } catch (e) {
    print("Google 로그인 오류: $e");
  }
}

// 사용자 정보 업로드
Future<void> handleUserInFirestore(Function callback) async {
  if (_user == null) return;

  final userRef = _firestore.collection('Users').doc(_user!.uid);
  final userDoc = await userRef.get();

  if (userDoc.exists) {
    // Firestore에 사용자 정보가 존재할 때
    final nickname = userDoc['nickname'] ?? 'Anonymous';
    final profileImage = userDoc['profileImage'] ?? '';
    print("Firestore에 저장된 사용자 정보 사용: 닉네임 - $nickname, 프로필 이미지 - $profileImage");
    callback(nickname, profileImage);
  } else {
    // Firestore에 사용자 정보가 없을 때, 구글 로그인 정보 사용
    final googleNickname = _user!.displayName ?? 'Anonymous';
    final googleProfileImage = _user!.photoURL ?? '';
    print(
        "Firestore에 사용자 정보가 없으므로 구글 로그인 정보 사용: 닉네임 - $googleNickname, 프로필 이미지 - $googleProfileImage");

    // Firestore에 새 사용자 정보 저장
    await userRef.set({
      'nickname': googleNickname,
      'profileImage': googleProfileImage,
    });

    callback(googleNickname, googleProfileImage);
  }
}

// userId 값으로 사용자 정보 가져오기
Future<void> fetchUserById(String userId, Function callback) async {
  if (userId.isEmpty) return;
  final userDoc = await _firestore.collection('Users').doc(userId).get();
  print("Firestore에서 가져온 데이터: ${userDoc.data()}");

  if (userDoc.exists) {
    final profileImage = userDoc['profileImage'] ?? '';
    // URL을 두 번 디코딩
    final decodedUrl = Uri.decodeFull(Uri.decodeFull(profileImage));
    print("디코딩된 프로필 이미지 URL: $decodedUrl");
    callback(userDoc['nickname'], decodedUrl);
  } else {
    callback('', '');
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
    print("이미지 선택 시작");

    // 1. 파일 선택
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      print("이미지 선택 취소됨");
      callback('');
      return;
    }

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    print("이미지 선택 완료: $fileName");

    // 2. Firebase Storage 참조 생성
    final storageRef = FirebaseStorage.instance.ref('profile_images/$fileName');

    // 3. 메타데이터 설정
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg', // 또는 'image/png' 등 적절한 형식
    );

    // 4. 파일 업로드 (메타데이터 포함)
    final uploadTask = storageRef.putData(fileBytes!, metadata);
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
