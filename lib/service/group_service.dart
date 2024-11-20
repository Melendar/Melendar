import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자가 처음 생성될 때 "개인그룹" 생성
  Future<void> createPersonalGroup(String userId) async {
    try {
      // "개인그룹"이라는 이름의 그룹 생성
      await _firestore.collection('Groups').add({
        'group_name': '개인그룹',
        'group_description': '',  // 빈 문자열로 설정
        'members': [userId],  // 생성된 userId를 members에 추가
      });
      print("개인그룹이 성공적으로 생성되었습니다.");
    } catch (e) {
      print("개인그룹 생성 중 오류 발생: $e");
    }
  }

  /// 새로운 그룹 생성
  Future<void> createGroup(String groupName, String groupDescription, List<String> memberIds) async {
    try {
      // 입력받은 groupName, groupDescription, memberIds로 그룹 생성
      await _firestore.collection('Groups').add({
        'group_name': groupName,
        'group_description': groupDescription,
        'members': memberIds,  // 입력받은 memberIds 배열을 members에 추가
      });
      print("새로운 그룹이 성공적으로 생성되었습니다.");
    } catch (e) {
      print("그룹 생성 중 오류 발생: $e");
    }
  }

  /// 특정 userId가 속한 모든 그룹을 조회
  Future<List<Map<String, dynamic>>> getGroupsByUser(String userId) async {
    try {
      // members 배열에 userId가 포함된 그룹만 조회
      QuerySnapshot snapshot = await _firestore.collection('Groups')
          .where('members', arrayContains: userId)
          .get();

      // 조회한 그룹 데이터를 List<Map> 형식으로 변환
      List<Map<String, dynamic>> groups = snapshot.docs.map((doc) {
        return {
          'group_id': doc.id,
          'group_name': doc['group_name'],
          'group_description': doc['group_description'],
          'members': doc['members'],
        };
      }).toList();

      return groups;
    } catch (e) {
      print("그룹 조회 중 오류 발생: $e");
      return [];
    }
  }

  /// 그룹 정보 업데이트 - 그룹원만 접근 가능
  Future<void> updateGroup(String groupId, String userId, String newGroupName, String newGroupDescription) async {
    try {
      // 그룹 문서 가져오기
      DocumentSnapshot groupDoc = await _firestore.collection('Groups').doc(groupId).get();

      if (groupDoc.exists) {
        // 그룹원인지 확인
        List<dynamic> members = groupDoc['members'];
        if (members.contains(userId)) {
          // 그룹원인 경우 그룹 이름과 설명 업데이트
          await _firestore.collection('Groups').doc(groupId).update({
            'group_name': newGroupName,
            'group_description': newGroupDescription,
          });
          print("그룹 정보가 성공적으로 업데이트되었습니다.");
        } else {
          print("권한이 없습니다: 그룹에 속한 사용자만 수정할 수 있습니다.");
        }
      } else {
        print("해당 그룹이 존재하지 않습니다.");
      }
    } catch (e) {
      print("그룹 정보 업데이트 중 오류 발생: $e");
    }
  }


/// 그룹 나가기 - 그룹에서 userId 제거, 멤버가 없으면 그룹 삭제
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      DocumentReference groupRef = _firestore.collection('Groups').doc(groupId);
      DocumentSnapshot groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        List<dynamic> members = groupDoc['members'];

        if (members.contains(userId)) {
          // 1. 그룹에서 userId 제거
          await groupRef.update({
            'members': FieldValue.arrayRemove([userId]),
          });
          print("$userId가 그룹에서 제거되었습니다.");

          // 2. 남아있는 멤버가 있는지 확인하고 없으면 그룹 삭제
          DocumentSnapshot updatedGroupDoc = await groupRef.get();
          List<dynamic> updatedMembers = updatedGroupDoc['members'];
          if (updatedMembers.isEmpty) {
            await deleteGroup(groupId);
          }
        } else {
          print("해당 사용자는 이 그룹의 멤버가 아닙니다.");
        }
      } else {
        print("해당 그룹이 존재하지 않습니다.");
      }
    } catch (e) {
      print("그룹 나가기 중 오류 발생: $e");
    }
  }

  /// 그룹 자체를 삭제
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('Groups').doc(groupId).delete();
      print("그룹이 성공적으로 삭제되었습니다.");
    } catch (e) {
      print("그룹 삭제 중 오류 발생: $e");
    }
  }

    /// 그룹에 멤버 추가 - 배열에 저장된 userIds를 members 필드에 추가
  Future<void> addGroupMember(String groupId, List<String> userIds) async {
    try {
      // 해당 그룹의 members 필드에 userIds 추가
      await _firestore.collection('Groups').doc(groupId).update({
        'members': FieldValue.arrayUnion(userIds),
      });
      print("그룹에 사용자들이 성공적으로 추가되었습니다.");
    } catch (e) {
      print("그룹에 사용자 추가 중 오류 발생: $e");
    }
  }


}


