import 'package:msgmorph/src/core/constants.dart';
import 'package:msgmorph/src/data/models/widget_item.dart';

/// Widget branding configuration
class WidgetBranding {
  const WidgetBranding({
    this.primaryColor,
    this.position,
    this.title,
    this.subtitle,
    this.logoUrl,
    this.thankYouMessage,
  });

  final String? primaryColor;
  final String? position;
  final String? title;
  final String? subtitle;
  final String? logoUrl;
  final String? thankYouMessage;

  factory WidgetBranding.fromJson(Map<String, dynamic> json) {
    return WidgetBranding(
      primaryColor: json['primaryColor'] as String?,
      position: json['position'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      logoUrl: json['logoUrl'] as String?,
      thankYouMessage: json['thankYouMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (primaryColor != null) 'primaryColor': primaryColor,
        if (position != null) 'position': position,
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (thankYouMessage != null) 'thankYouMessage': thankYouMessage,
      };
}

/// Custom field configuration
class CustomField {
  const CustomField({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    this.options,
  });

  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type,
        'required': required,
        if (options != null) 'options': options,
      };
}

/// Pre-chat form field configuration
class PreChatFormField {
  const PreChatFormField({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    this.options,
  });

  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;

  factory PreChatFormField.fromJson(Map<String, dynamic> json) {
    return PreChatFormField(
      id: json['id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

/// Pre-chat form configuration
class PreChatForm {
  const PreChatForm({
    required this.enabled,
    required this.fields,
  });

  final bool enabled;
  final List<PreChatFormField> fields;

  factory PreChatForm.fromJson(Map<String, dynamic> json) {
    return PreChatForm(
      enabled: json['enabled'] as bool? ?? false,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => PreChatFormField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Widget configuration model
class WidgetConfig {
  const WidgetConfig({
    this.id,
    required this.projectId,
    required this.publicId,
    this.isEnabled,
    required this.branding,
    required this.items,
    required this.collectEmail,
    required this.collectName,
    this.customFields,
    this.liveChatGreeting,
    this.offlineMessage,
    this.showWaitTime,
    this.preChatForm,
  });

  final String? id;
  final String projectId;
  final String publicId;
  final bool? isEnabled;
  final WidgetBranding branding;
  final List<WidgetItem> items;
  final CollectionRequirement collectEmail;
  final CollectionRequirement collectName;
  final List<CustomField>? customFields;
  final String? liveChatGreeting;
  final String? offlineMessage;
  final bool? showWaitTime;
  final PreChatForm? preChatForm;

  /// Get primary color with fallback
  String get primaryColor => branding.primaryColor ?? '#000000';

  /// Get enabled feedback types (excluding LIVE_CHAT and LINK)
  List<WidgetItem> get feedbackItems => items
      .where((item) =>
          item.isEnabled && item.type != 'LIVE_CHAT' && item.type != 'LINK')
      .toList();

  /// Check if live chat is enabled
  bool get hasLiveChat =>
      items.any((item) => item.isEnabled && item.type == 'LIVE_CHAT');

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      id: json['id'] as String?,
      projectId: json['projectId'] as String,
      publicId: json['publicId'] as String,
      isEnabled: json['isEnabled'] as bool?,
      branding: WidgetBranding.fromJson(
          json['branding'] as Map<String, dynamic>? ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => WidgetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      collectEmail: CollectionRequirement.fromString(
          json['collectEmail'] as String? ?? 'none'),
      collectName: CollectionRequirement.fromString(
          json['collectName'] as String? ?? 'none'),
      customFields: (json['customFields'] as List<dynamic>?)
          ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
          .toList(),
      liveChatGreeting: json['liveChatGreeting'] as String?,
      offlineMessage: json['offlineMessage'] as String?,
      showWaitTime: json['showWaitTime'] as bool?,
      preChatForm: json['preChatForm'] != null
          ? PreChatForm.fromJson(json['preChatForm'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'projectId': projectId,
        'publicId': publicId,
        if (isEnabled != null) 'isEnabled': isEnabled,
        'branding': branding.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'collectEmail': collectEmail.value,
        'collectName': collectName.value,
        if (customFields != null)
          'customFields': customFields!.map((e) => e.toJson()).toList(),
        if (liveChatGreeting != null) 'liveChatGreeting': liveChatGreeting,
        if (offlineMessage != null) 'offlineMessage': offlineMessage,
        if (showWaitTime != null) 'showWaitTime': showWaitTime,
      };
}
