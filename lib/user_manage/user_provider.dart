import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/group_service.dart';
import '../service/user_service.dart';

// group model이나 이 provider 쓰느라 코드가 꽤 꼬임... 
class UserProvider with ChangeNotifier {
  User? _user;
  String _nickname = '';
  String _profileImageUrl = '';
  List<Map<String, dynamic>> _groups = [];
  Map<String, String> _memberNicknames = {};
  final GroupService _groupService = GroupService();

  // 그룹 필터링을 위한 상태 추가
  Set<String> _selectedGroupIds = {};

  User? get user => _user;
  String get nickname => _nickname;
  String get profileImageUrl => _profileImageUrl;
  // 사용자가 속한 그룹 정보도 여기서 관리
  List<Map<String, dynamic>> get groups => _groups;
  Map<String, String> get memberNicknames => _memberNicknames;
  // 선택된 그룹 ID getter
  Set<String> get selectedGroupIds => _selectedGroupIds;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setUserInfo(String nickname, String profileImageUrl) {
    _nickname = nickname;
    _profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  Future<void> fetchGroups() async {
    if (_user == null) return;
    try {
      final groupsList = await _groupService.getGroupsByUser(_user!.uid);
      _groups = groupsList;
      
      // 초기에 모든 그룹 선택
      _selectedGroupIds = groupsList.map((group) => group['group_id'] as String).toSet();
      
      // 그룹 멤버들의 닉네임 가져오기
      for (var group in groupsList) {
        List<String> members = List<String>.from(group['members']);
        for (String memberId in members) {
          if (!_memberNicknames.containsKey(memberId)) {
            try {
              final userProfile = await fetchUserById(memberId);
              if (userProfile != null) {
                _memberNicknames[memberId] = userProfile.nickname;
              }
            } catch (e) {
              print('Error fetching member nickname: $e');
            }
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  void setGroups(List<Map<String, dynamic>> groups) {
    _groups = groups;
    notifyListeners();
  }

  // 그룹 변동사항 있을 때마다 백한테 데이터 새로 받으면 번거로움
  void addGroup(Map<String, dynamic> group) {
    _groups.add(group);
    // 새 그룹 멤버들의 닉네임 업데이트
    List<String> members = List<String>.from(group['members']);
    for (String memberId in members) {
      if (!_memberNicknames.containsKey(memberId)) {
        fetchUserById(memberId).then((userProfile) {
          if (userProfile != null) {
            _memberNicknames[memberId] = userProfile.nickname;
            notifyListeners();
          }
        });
      }
    }
    // 새 그룹 자동 선택
    _selectedGroupIds.add(group['group_id']);
    notifyListeners();
  }

  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group['group_id'] == groupId);
    _selectedGroupIds.remove(groupId);
    notifyListeners();
  }

  // 그룹 정보 바뀔 때 업데이트해주기
  void updateGroup(String groupId, Map<String, dynamic> updatedGroup) {
    int index = _groups.indexWhere((group) => group['group_id'] == groupId);
    if (index != -1) {
      _groups[index] = updatedGroup;
      // 업데이트된 멤버들의 닉네임 가져오기
      List<String> members = List<String>.from(updatedGroup['members']);
      for (String memberId in members) {
        if (!_memberNicknames.containsKey(memberId)) {
          fetchUserById(memberId).then((userProfile) {
            if (userProfile != null) {
              _memberNicknames[memberId] = userProfile.nickname;
              notifyListeners();
            }
          });
        }
      }
      notifyListeners();
    }
  }

  // 멤버 닉네임 가져오기
  String getMemberNickname(String memberId) {
    return _memberNicknames[memberId] ?? memberId;
  }

  // 로그아웃시 정보 없애는 함수임
  void clearUser() {
    _user = null;
    _nickname = '';
    _profileImageUrl = '';
    _groups = [];
    _memberNicknames.clear();
    _selectedGroupIds.clear();
    _groupColors.clear();
    _usedColors.clear();
    notifyListeners();
  }

  void updateGroups(List<Map<String, dynamic>> newGroups) {
    _groups = newGroups;
    notifyListeners();
  }

  // 색 설정 관련 코드들 추가!
  Map<String, Color> _groupColors = {};
  final List<Color> _availableColors = [
    Color(0xFFfd7f6f), 
    Color(0xFF7eb0d5), 
    Color(0xFFb2e061), 
    Color(0xFFbd7ebe), 
    Color(0xFFffb55a), 
    Color(0xFFffee65), 
    Color(0xFFbeb9db), 
    Color(0xFFfdcce5), 
    Color(0xFF8bd3c7), 
  ];
  Set<Color> _usedColors = {};

  // 그룹 색상 getter
  Map<String, Color> get groupColors => _groupColors;

  // 그룹 색상 가져오기
  Color getGroupColor(String groupId) {
    if (!_groupColors.containsKey(groupId)) {
      // 사용 가능한 색상 중에서 선택
      Color newColor = _getNextAvailableColor();
      _groupColors[groupId] = newColor;
      _usedColors.add(newColor);
    }
    return _groupColors[groupId]!;
  }

  // 사용 가능한 다음 색상 가져오기
  Color _getNextAvailableColor() {
    // 모든 색상이 사용된 경우 초기화
    if (_usedColors.length >= _availableColors.length) {
      _usedColors.clear();
    }
    
    // 사용되지 않은 색상 찾기
    for (Color color in _availableColors) {
      if (!_usedColors.contains(color)) {
        return color;
      }
    }
    
    // 만약을 위한 폴백 (일어나선 안 됨)
    return _availableColors[0];
  }

  // 그룹이 삭제될 때 색상도 제거
  void removeGroupColor(String groupId) {
    if (_groupColors.containsKey(groupId)) {
      _usedColors.remove(_groupColors[groupId]);
      _groupColors.remove(groupId);
    }
  }

  // 그룹 필터링 관련 메서드들
  // 초기화 - 모든 그룹 선택
  void initializeSelectedGroups() {
    _selectedGroupIds = _groups.map((group) => group['group_id'] as String).toSet();
    notifyListeners();
  }

  // 그룹 선택/해제 토글
  void toggleGroupSelection(String groupId) {
    if (_selectedGroupIds.contains(groupId)) {
      _selectedGroupIds.remove(groupId);
    } else {
      _selectedGroupIds.add(groupId);
    }
    notifyListeners();
  }

  // 모든 그룹 선택
  void selectAllGroups() {
    _selectedGroupIds = _groups.map((group) => group['group_id'] as String).toSet();
    notifyListeners();
  }

  // 모든 그룹 선택 해제
  void unselectAllGroups() {
    _selectedGroupIds.clear();
    notifyListeners();
  }

  // 그룹이 선택되었는지 확인
  bool isGroupSelected(String groupId) {
    return _selectedGroupIds.contains(groupId);
  }
}