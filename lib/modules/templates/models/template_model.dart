import 'package:flutter/material.dart';

class TemplateComponentModel {
  final String type; // HEADER, BODY, FOOTER, BUTTONS, CAROUSEL
  final String? format; // TEXT, IMAGE, VIDEO, DOCUMENT, LOCATION
  final String? text;
  final Map<String, dynamic>? example;
  final List<TemplateButtonModel>? buttons;
  final List<Map<String, dynamic>>? cards;

  TemplateComponentModel({
    required this.type,
    this.format,
    this.text,
    this.example,
    this.buttons,
    this.cards,
  });

  factory TemplateComponentModel.fromJson(Map<String, dynamic> json) {
    List<TemplateButtonModel>? parsedButtons;
    if (json['buttons'] != null && json['buttons'] is List) {
      parsedButtons = (json['buttons'] as List)
          .whereType<Map>()
          .map((b) => TemplateButtonModel.fromJson(Map<String, dynamic>.from(b)))
          .toList();
    }

    List<Map<String, dynamic>>? parsedCards;
    if (json['cards'] != null && json['cards'] is List) {
      parsedCards = (json['cards'] as List)
          .whereType<Map>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    }

    Map<String, dynamic>? parsedExample;
    if (json['example'] != null) {
      if (json['example'] is Map) {
        parsedExample = Map<String, dynamic>.from(json['example'] as Map);
      } else if (json['example'] is List) {
        parsedExample = {'header_handle': json['example'], 'sample_text': json['example']};
      }
    }

    return TemplateComponentModel(
      type: (json['type'] ?? '').toString().toUpperCase(),
      format: json['format']?.toString().toUpperCase(),
      text: json['text']?.toString(),
      example: parsedExample,
      buttons: parsedButtons,
      cards: parsedCards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (format != null) 'format': format,
      if (text != null) 'text': text,
      if (example != null) 'example': example,
      if (buttons != null) 'buttons': buttons!.map((b) => b.toJson()).toList(),
      if (cards != null) 'cards': cards,
    };
  }
}

class TemplateButtonModel {
  final String type; // QUICK_REPLY, PHONE_NUMBER, URL, OTP
  final String text;
  final String? url;
  final String? phoneNumber;

  TemplateButtonModel({
    required this.type,
    required this.text,
    this.url,
    this.phoneNumber,
  });

  factory TemplateButtonModel.fromJson(Map<String, dynamic> json) {
    return TemplateButtonModel(
      type: (json['type'] ?? 'QUICK_REPLY').toString().toUpperCase(),
      text: (json['text'] ?? json['title'] ?? '').toString(),
      url: json['url']?.toString(),
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      if (url != null) 'url': url,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}

class TemplateModel {
  final String? id;
  final String name;
  final String label;
  final String status; // APPROVED, PENDING, REJECTED, DISABLED, PAUSED
  final String category; // MARKETING, UTILITY, AUTHENTICATION
  final String language;
  final String? text;
  final dynamic sampleText;
  final dynamic qualityScore;
  final String? rejectedReason;
  final int? createdAt;
  final int? updatedAt;
  final String? projectId;
  final String? businessId;
  final List<TemplateComponentModel> components;
  final List<TemplateButtonModel> buttons;

  TemplateModel({
    this.id,
    required this.name,
    required this.label,
    required this.status,
    required this.category,
    required this.language,
    this.text,
    this.sampleText,
    this.qualityScore,
    this.rejectedReason,
    this.createdAt,
    this.updatedAt,
    this.projectId,
    this.businessId,
    required this.components,
    required this.buttons,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    List<TemplateComponentModel> parsedComponents = [];
    if (json['components'] != null && json['components'] is List) {
      parsedComponents = (json['components'] as List)
          .whereType<Map>()
          .map((c) => TemplateComponentModel.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    List<TemplateButtonModel> parsedButtons = [];
    if (json['buttons'] != null && json['buttons'] is List) {
      for (var b in (json['buttons'] as List)) {
        if (b is Map) {
          parsedButtons.add(TemplateButtonModel.fromJson(Map<String, dynamic>.from(b)));
        }
      }
    } else if (json['call_to_action'] != null && json['call_to_action'] is List) {
      for (var item in json['call_to_action']) {
        if (item is Map) {
          if (item['buttons'] != null && item['buttons'] is List) {
            for (var b in (item['buttons'] as List)) {
              if (b is Map) {
                parsedButtons.add(TemplateButtonModel.fromJson(Map<String, dynamic>.from(b)));
              }
            }
          } else if (item['type'] != null && (item['text'] != null || item['title'] != null)) {
            parsedButtons.add(TemplateButtonModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    }

    final nameStr = (json['name'] ?? '').toString();
    final bodyComp = parsedComponents.firstWhere(
      (c) => c.type == 'BODY',
      orElse: () => TemplateComponentModel(type: 'BODY'),
    );

    return TemplateModel(
      id: json['id']?.toString(),
      name: nameStr,
      label: (json['label'] ?? nameStr).toString(),
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      category: (json['category'] ?? 'MARKETING').toString().toUpperCase(),
      language: (json['language'] ?? 'en_US').toString(),
      text: json['text']?.toString() ?? bodyComp.text,
      sampleText: json['sample_text'] ?? json['sampleText'],
      qualityScore: json['quality_score'] ?? json['qualityScore'],
      rejectedReason: json['rejected_reason']?.toString() ?? json['rejectedReason']?.toString(),
      createdAt: json['created_at'] != null ? int.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? int.tryParse(json['updated_at'].toString()) : null,
      projectId: json['project_id']?.toString(),
      businessId: json['business_id']?.toString(),
      components: parsedComponents,
      buttons: parsedButtons,
    );
  }


  TemplateComponentModel? get headerComponent {
    try {
      return components.firstWhere((c) => c.type == 'HEADER');
    } catch (_) {
      return null;
    }
  }

  TemplateComponentModel? get bodyComponent {
    try {
      return components.firstWhere((c) => c.type == 'BODY');
    } catch (_) {
      return null;
    }
  }

  TemplateComponentModel? get footerComponent {
    try {
      return components.firstWhere((c) => c.type == 'FOOTER');
    } catch (_) {
      return null;
    }
  }

  TemplateComponentModel? get carouselComponent {
    try {
      return components.firstWhere((c) => c.type == 'CAROUSEL');
    } catch (_) {
      return null;
    }
  }

  List<String> get variableIndices {
    final bodyTextStr = text ?? bodyComponent?.text ?? '';
    final headerTextStr = headerComponent?.text ?? '';
    final allText = '$headerTextStr $bodyTextStr';
    final regExp = RegExp(r'\{\{(\d+)\}\}');
    final matches = regExp.allMatches(allText);
    final Set<String> indices = {};
    for (final match in matches) {
      if (match.group(1) != null) {
        indices.add(match.group(1)!);
      }
    }
    final list = indices.toList()..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    return list;
  }

  Color get statusColor {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF00B074);
      case 'REJECTED':
      case 'FAILED':
        return const Color(0xFFEF4444);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF00B074).withValues(alpha: 0.12);
      case 'REJECTED':
      case 'FAILED':
        return const Color(0xFFEF4444).withValues(alpha: 0.12);
      case 'PENDING':
        return const Color(0xFFF59E0B).withValues(alpha: 0.12);
      default:
        return const Color(0xFF64748B).withValues(alpha: 0.12);
    }
  }

}
