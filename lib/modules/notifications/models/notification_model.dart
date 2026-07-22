class NotificationItemModel {
  final String id;
  final String? projectId;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final String action;
  final String module;
  final String? target;
  final String? details;
  final String status;
  final int? createdAt;
  final String? createdAtIso;
  bool isRead;

  NotificationItemModel({
    required this.id,
    this.projectId,
    this.userId,
    this.userEmail,
    this.userName,
    required this.action,
    required this.module,
    this.target,
    this.details,
    required this.status,
    this.createdAt,
    this.createdAtIso,
    this.isRead = false,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json, {int? lastReadAt}) {
    final createdTime = json['created_at'] is int ? json['created_at'] as int : null;
    bool read = false;
    if (lastReadAt != null && createdTime != null) {
      read = createdTime <= lastReadAt;
    }

    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      userId: json['user_id']?.toString(),
      userEmail: json['user_email']?.toString(),
      userName: json['user_name']?.toString(),
      action: json['action']?.toString() ?? 'activity',
      module: json['module']?.toString() ?? 'system',
      target: json['target']?.toString(),
      details: json['details']?.toString(),
      status: json['status']?.toString() ?? 'success',
      createdAt: createdTime,
      createdAtIso: json['created_at_iso']?.toString(),
      isRead: read,
    );
  }
}

class NotificationModuleSummaryModel {
  final String module;
  final int count;
  final double percent;

  NotificationModuleSummaryModel({
    required this.module,
    required this.count,
    required this.percent,
  });

  factory NotificationModuleSummaryModel.fromJson(Map<String, dynamic> json) {
    return NotificationModuleSummaryModel(
      module: json['module']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : 0,
      percent: (json['percent'] is num) ? (json['percent'] as num).toDouble() : 0.0,
    );
  }
}
