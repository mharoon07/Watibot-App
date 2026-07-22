class MediaItemModel {
  final String id;
  final String name;
  final String url;
  final String type; // image, gif, audio, video, document
  final int? createdAt;
  final String? createdAtIso;
  final String? projectId;

  MediaItemModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.createdAt,
    this.createdAtIso,
    this.projectId,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      type: (json['type'] ?? 'image').toString().toLowerCase(),
      createdAt: json['created_at'] != null ? int.tryParse(json['created_at'].toString()) : null,
      createdAtIso: json['created_at_iso']?.toString(),
      projectId: (json['project_id'] ?? json['organizationId'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'created_at': createdAt,
      'created_at_iso': createdAtIso,
      'project_id': projectId,
    };
  }

  String get formattedDate {
    if (createdAtIso != null && createdAtIso!.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAtIso!);
        return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
      } catch (_) {}
    }
    if (createdAt != null) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(createdAt!);
        return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
      } catch (_) {}
    }
    return '';
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
