class UsageOverviewModel {
  final int totalQuota;
  final int usedQuota;
  final int remainingQuota;
  final double percentage;
  final List<QuotaResource> resources;

  UsageOverviewModel({
    required this.totalQuota,
    required this.usedQuota,
    required this.remainingQuota,
    required this.percentage,
    required this.resources,
  });

  factory UsageOverviewModel.fromJson(Map<String, dynamic> json) {
    return UsageOverviewModel(
      totalQuota: json['total_quota'] ?? 0,
      usedQuota: json['used_quota'] ?? 0,
      remainingQuota: json['remaining_quota'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => QuotaResource.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quota': totalQuota,
      'used_quota': usedQuota,
      'remaining_quota': remainingQuota,
      'percentage': percentage,
      'resources': resources.map((e) => e.toJson()).toList(),
    };
  }
}

class QuotaResource {
  final String key;
  final String name;
  final int used;
  final int limit;
  final bool unlimited;
  final int? remaining;
  final double percentage;

  QuotaResource({
    required this.key,
    required this.name,
    required this.used,
    required this.limit,
    required this.unlimited,
    this.remaining,
    required this.percentage,
  });

  factory QuotaResource.fromJson(Map<String, dynamic> json) {
    return QuotaResource(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      used: json['used'] ?? 0,
      limit: json['limit'] ?? 0,
      unlimited: json['unlimited'] ?? false,
      remaining: json['remaining'],
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'used': used,
      'limit': limit,
      'unlimited': unlimited,
      'remaining': remaining,
      'percentage': percentage,
    };
  }
}
