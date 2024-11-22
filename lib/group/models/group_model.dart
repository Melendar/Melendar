class Group {
  final String id;
  final String name;
  final String description;
  final List<String> members;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
  });

// Group을 만들버려서 기존 형식이랑 혼용되고 있음, 변환함수
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['group_id'],
      name: json['group_name'],
      description: json['group_description'],
      members: List<String>.from(json['members']),
    );
  }
}