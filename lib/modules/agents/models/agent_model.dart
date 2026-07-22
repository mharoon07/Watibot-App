class DepartmentModel {
  final String id;
  final String? projectId;
  final String name;
  final String? description;
  final int usersCount;
  final int? createdAt;
  final String? createdAtIso;

  DepartmentModel({
    required this.id,
    this.projectId,
    required this.name,
    this.description,
    this.usersCount = 0,
    this.createdAt,
    this.createdAtIso,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      usersCount: json['users_count'] is int ? json['users_count'] : 0,
      createdAt: json['created_at'] is int ? json['created_at'] : null,
      createdAtIso: json['created_at_iso']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'description': description,
      'users_count': usersCount,
      'created_at': createdAt,
      'created_at_iso': createdAtIso,
    };
  }
}

class LatestDeviceModel {
  final String id;
  final String? deviceId;
  final String? deviceName;
  final bool notificationsEnabled;
  final int? lastActiveAt;
  final String? lastActiveAtIso;

  LatestDeviceModel({
    required this.id,
    this.deviceId,
    this.deviceName,
    this.notificationsEnabled = true,
    this.lastActiveAt,
    this.lastActiveAtIso,
  });

  factory LatestDeviceModel.fromJson(Map<String, dynamic> json) {
    return LatestDeviceModel(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString(),
      deviceName: json['device_name']?.toString(),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      lastActiveAt: json['last_active_at'] is int ? json['last_active_at'] : null,
      lastActiveAtIso: json['last_active_at_iso']?.toString(),
    );
  }
}

class AgentModel {
  final String id;
  final String? projectId;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? phoneNumber;
  final Map<String, dynamic> permissions;
  final bool onboardingCompleted;
  final DepartmentModel? department;
  final int? assignedContactsCount;
  final int? sentMessagesCount;
  final LatestDeviceModel? latestDevice;
  final int? lastLoginAt;
  final String? lastLoginAtIso;
  final int? createdAt;
  final String? createdAtIso;

  AgentModel({
    required this.id,
    this.projectId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.phoneNumber,
    this.permissions = const {},
    this.onboardingCompleted = true,
    this.department,
    this.assignedContactsCount,
    this.sentMessagesCount,
    this.latestDevice,
    this.lastLoginAt,
    this.lastLoginAtIso,
    this.createdAt,
    this.createdAtIso,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      name: json['name']?.toString() ?? (json['email']?.toString().split('@').first ?? 'Agent'),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'USER',
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      phoneNumber: json['phone_number']?.toString(),
      permissions: json['permissions'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['permissions'])
          : {},
      onboardingCompleted: json['onboarding_completed'] ?? true,
      department: json['department'] != null && json['department'] is Map<String, dynamic>
          ? DepartmentModel.fromJson(json['department'])
          : null,
      assignedContactsCount: json['assigned_contacts_count'] is int ? json['assigned_contacts_count'] : null,
      sentMessagesCount: json['sent_messages_count'] is int ? json['sent_messages_count'] : null,
      latestDevice: json['latest_device'] != null && json['latest_device'] is Map<String, dynamic>
          ? LatestDeviceModel.fromJson(json['latest_device'])
          : null,
      lastLoginAt: json['last_login_at'] is int ? json['last_login_at'] : null,
      lastLoginAtIso: json['last_login_at_iso']?.toString(),
      createdAt: json['created_at'] is int ? json['created_at'] : null,
      createdAtIso: json['created_at_iso']?.toString(),
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
}

class PermissionModuleModel {
  final String key;
  final String name;
  final List<String> accessLevels;

  PermissionModuleModel({
    required this.key,
    required this.name,
    required this.accessLevels,
  });

  factory PermissionModuleModel.fromJson(Map<String, dynamic> json) {
    return PermissionModuleModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      accessLevels: (json['access_levels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['full', 'edit', 'delete', 'view', 'none', 'custom'],
    );
  }
}
