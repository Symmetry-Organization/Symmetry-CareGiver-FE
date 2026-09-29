class NotificationModelData{
  final int notifyId;
  final int userId;
  final String type;
  final String title;
  final String body;
  // final String data;
  bool isRead;
  final int callId;
  final String createdAt;
  final String updatedAt;

  /// Raw ISO timestamp — [createdAt] is already the "1h ago" label.
  final String createdAtIso;
  NotificationModelData({
    required this.type,
    required this.notifyId,
    required this.userId,
    required this.title,
    required this.body,
    // required this.data,
    required this.isRead,
    required this.callId,
    required this.createdAt,
    required this.updatedAt,
    this.createdAtIso = '',
  });
}