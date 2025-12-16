/// Widget menu item model
class WidgetItem {
  const WidgetItem({
    required this.id,
    required this.type,
    required this.label,
    required this.isEnabled,
    this.icon,
    this.meta,
  });

  final String id;
  final String type;
  final String label;
  final bool isEnabled;
  final String? icon;
  final dynamic meta;

  /// Check if this is a feedback type item
  bool get isFeedbackType =>
      type == 'ISSUE' ||
      type == 'FEATURE_REQUEST' ||
      type == 'FEEDBACK' ||
      type == 'OTHER';

  /// Check if this is a live chat item
  bool get isLiveChat => type == 'LIVE_CHAT';

  /// Check if this is a link item
  bool get isLink => type == 'LINK';

  /// Get emoji for feedback type
  String get emoji {
    switch (type) {
      case 'ISSUE':
        return '🐛';
      case 'FEATURE_REQUEST':
        return '💡';
      case 'FEEDBACK':
        return '💬';
      case 'OTHER':
        return '✨';
      case 'LIVE_CHAT':
        return '💬';
      default:
        return '📝';
    }
  }

  /// Get placeholder text for feedback type
  String get placeholder {
    switch (type) {
      case 'ISSUE':
        return 'I found a bug when...';
      case 'FEATURE_REQUEST':
        return 'It would be great if...';
      case 'FEEDBACK':
        return 'I think...';
      case 'OTHER':
        return 'I wanted to say...';
      default:
        return 'Enter your message...';
    }
  }

  factory WidgetItem.fromJson(Map<String, dynamic> json) {
    return WidgetItem(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      isEnabled: json['isEnabled'] as bool? ?? json['enabled'] as bool? ?? true,
      icon: json['icon'] as String?,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'label': label,
    'isEnabled': isEnabled,
    if (icon != null) 'icon': icon,
    if (meta != null) 'meta': meta,
  };
}
