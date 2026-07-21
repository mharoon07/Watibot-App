class RecentActivityModel {
  final String id;
  final String module;
  final String action;
  final String status;
  final String? target;
  final String? details;
  final String? userName;
  final String? userEmail;
  final DateTime? createdAt;

  RecentActivityModel({
    required this.id,
    required this.module,
    required this.action,
    required this.status,
    this.target,
    this.details,
    this.userName,
    this.userEmail,
    this.createdAt,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] ?? '',
      module: json['module'] ?? '',
      action: json['action'] ?? '',
      status: json['status'] ?? '',
      target: json['target'],
      details: json['details'],
      userName: json['user_name'] ?? json['userName'],
      userEmail: json['user_email'] ?? json['userEmail'],
      createdAt: json['created_at_iso'] != null
          ? DateTime.tryParse(json['created_at_iso'])
          : (json['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
              : (json['created_at'] != null
                  ? DateTime.tryParse(json['created_at'].toString())
                  : null)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'action': action,
      'status': status,
      'target': target,
      'details': details,
      'user_name': userName,
      'user_email': userEmail,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Getters for UI display
  String get displayTitle {
    if (target != null && target!.isNotEmpty) return target!;
    return '${module[0].toUpperCase()}${module.substring(1)} $action';
  }

  String get displaySubtitle {
    if (details != null && details!.isNotEmpty) return details!;
    return '$module has been $action';
  }

  String get type {
    return module.toLowerCase();
  }
}
