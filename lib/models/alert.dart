class Alert {
  final String uid;
  final String? notificationId;
  final DateTime notifiedTime;
  final String notificationContext;
  List<String> readBy;

  Alert({
    required this.uid,
    required this.notificationId,
    required this.notifiedTime,
    required this.notificationContext,
    required this.readBy,
  });

  factory Alert.fromJson(Map<String, dynamic> data) {
    return Alert(
      uid: data['uid'],
      notificationId: data['notification_id'],
      notifiedTime: DateTime.parse(data['notified_time']),
      notificationContext: data['notification_context'],
      readBy: data['read_by'] as List<String>,
    );
  }
}
