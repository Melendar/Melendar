import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  List<Map<String, dynamic>> _groups = [];

  User? get user => _user;
  String get nickname => _nickname;
  String get profileImageUrl => _profileImageUrl;
  // 사용자가 속한 그룹 정보도 여기서 관리
  List<Map<String, dynamic>> get groups => _groups;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setUserInfo(String nickname, String profileImageUrl) {
    _nickname = nickname;
    _profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  void setGroups(List<Map<String, dynamic>> groups) {
    _groups = groups;
    notifyListeners();
  }

 // 그룹 변동사항 있을 때마다 백한테 데이터 새로 받으면 번거로움
  void addGroup(Map<String, dynamic> group) {
    _groups.add(group);
    notifyListeners();
  }

  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group['group_id'] == groupId);
    notifyListeners();
  }

  // 그룹 정보 바뀔 때 업데이트해주기
  void updateGroup(String groupId, Map<String, dynamic> updatedGroup) {
    int index = _groups.indexWhere((group) => group['group_id'] == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  // 로그아웃시 정보 없애는 함수임
  void clearUser() {
    _user = null;
    _nickname = '';
    _profileImageUrl = '';
    _groups = [];
    notifyListeners();
  }
}
