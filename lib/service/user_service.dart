import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? _user;

Future<void> signInWithGoogle() async {
  try {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
    _user = userCredential.user;
  } catch (e) {
    print("Google 로그인 오류: $e");
  }
}

Future<void> handleUserInFirestore() async {
  if (_user == null) return;

  final userRef = _firestore.collection('Users').doc(_user!.uid);
  final userDoc = await userRef.get();

  if (!userDoc.exists) {
    await userRef.set({
      'userId': _user!.uid,
      'nickname': _user!.displayName ?? 'Anonymous',
      'profileImage': _user!.photoURL ?? '',
    });
  }
}

Future<void> fetchUserById(String userId, Function callback) async {
  if (userId.isEmpty) return;
  final userDoc = await _firestore.collection('Users').doc(userId).get();

  if (userDoc.exists) {
    callback(userDoc['nickname'], userDoc['profileImage']);
  } else {
    callback('', '');
  }
}

Future<void> updateNickname(String newNickname, Function callback) async {
  if (_user == null || newNickname.isEmpty) return;
  await _firestore.collection('Users').doc(_user!.uid).update({
    'nickname': newNickname,
  });
  callback(newNickname);
}

Future<void> updateProfileImage(String newProfileImageUrl, Function callback) async {
  if (_user == null || newProfileImageUrl.isEmpty) return;
  await _firestore.collection('Users').doc(_user!.uid).update({
    'profileImage': newProfileImageUrl,
  });
  callback(newProfileImageUrl);
}
