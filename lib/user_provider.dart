import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';

  User? get user => _user;
  String get nickname => _nickname;
  String get profileImageUrl => _profileImageUrl;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setUserInfo(String nickname, String profileImageUrl) {
    _nickname = nickname;
    _profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _nickname = '';
    _profileImageUrl = '';
    notifyListeners();
  }
}
