class Notification {
  final String uid;
  final String? notificationId;
  final DateTime notifiedTime;
  final String notificationContext;
  List<String> readBy;

  Notification({
    required this.uid,
    required this.notificationId,
    required this.notifiedTime,
    required this.notificationContext,
    required this.readBy,
  });

  factory Notification.fromJson(Map<String, dynamic> data) {
    return Notification(
      uid: data['uid'] ?? '',
      notificationId: data['notification_id'],
      notifiedTime: DateTime.parse(data['notified_time']),
      notificationContext: data['notification_context'],
      readBy: data['read_by'] as List<String>,
    );
  }
}
