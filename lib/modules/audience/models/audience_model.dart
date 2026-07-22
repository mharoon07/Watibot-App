class CountryDistributionModel {
  final String name;
  final String code;
  final int count;
  final double percent;
  final String flag;

  CountryDistributionModel({
    required this.name,
    required this.code,
    required this.count,
    required this.percent,
    required this.flag,
  });

  factory CountryDistributionModel.fromJson(Map<String, dynamic> json) {
    return CountryDistributionModel(
      name: json['name']?.toString() ?? 'Other',
      code: json['code']?.toString() ?? 'un',
      count: json['count'] is int ? json['count'] : 0,
      percent: (json['percent'] is num) ? (json['percent'] as num).toDouble() : 0.0,
      flag: json['flag']?.toString() ?? '',
    );
  }
}

class AudienceSummaryModel {
  final String id;
  final String title;
  final String description;
  final int contacts;
  final String contactsLabel;
  final int growthLast7Days;
  final String growth;
  final String status;
  final List<CountryDistributionModel> topCountries;

  AudienceSummaryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.contacts,
    required this.contactsLabel,
    required this.growthLast7Days,
    required this.growth,
    required this.status,
    required this.topCountries,
  });

  factory AudienceSummaryModel.fromJson(Map<String, dynamic> json) {
    final countriesList = (json['top_countries'] as List<dynamic>?)
            ?.map((e) => CountryDistributionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AudienceSummaryModel(
      id: json['id']?.toString() ?? 'chat-audience',
      title: json['title']?.toString() ?? 'Chat Audience',
      description: json['description']?.toString() ?? 'All contacts with active chat history',
      contacts: json['contacts'] is int ? json['contacts'] : 0,
      contactsLabel: json['contacts_label']?.toString() ?? '0',
      growthLast7Days: json['growth_last_7_days'] is int ? json['growth_last_7_days'] : 0,
      growth: json['growth']?.toString() ?? '+0',
      status: json['status']?.toString() ?? 'Active',
      topCountries: countriesList,
    );
  }
}

class AudienceSegmentModel {
  final String id;
  final String type; // 'tag' or 'group'
  final String title;
  final String? color;
  final String? category;
  final String? description;
  final int contacts;
  final int? createdAt;
  final String? createdAtIso;

  AudienceSegmentModel({
    required this.id,
    required this.type,
    required this.title,
    this.color,
    this.category,
    this.description,
    required this.contacts,
    this.createdAt,
    this.createdAtIso,
  });

  factory AudienceSegmentModel.fromJson(Map<String, dynamic> json) {
    return AudienceSegmentModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'tag',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Segment',
      color: json['color']?.toString() ?? '#10B981',
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      contacts: json['contacts'] is int ? json['contacts'] : 0,
      createdAt: json['created_at'] is int ? json['created_at'] : null,
      createdAtIso: json['created_at_iso']?.toString(),
    );
  }

  bool get isTag => type == 'tag';
  bool get isGroup => type == 'group';
}
