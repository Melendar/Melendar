class FirebaseEventData {
  final String id;
  final String title;
  final DateTime date;
  final String userId;

  FirebaseEventData({
    required this.id,
    required this.title,
    required this.date,
    required this.userId,
  });

  factory FirebaseEventData.fromMap(Map<String, dynamic> map) {
    return FirebaseEventData(
      id: map['event_id'],
      title: map['task'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_id': id,
      'task': title,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }
}
