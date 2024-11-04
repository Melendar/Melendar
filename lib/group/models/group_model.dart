class Group {
  final String name;
  final String description;
  final List<String> members;
  final bool isAdmin;

  Group({
    required this.name,
    required this.description,
    required this.members,
    required this.isAdmin,
  });
}