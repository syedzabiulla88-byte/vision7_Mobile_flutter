class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final String createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
