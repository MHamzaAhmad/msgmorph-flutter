/// Device context for feedback submission
class DeviceContext {
  const DeviceContext({
    this.screenWidth,
    this.screenHeight,
    this.platform,
    this.language,
    this.timezone,
    this.appVersion,
  });

  final int? screenWidth;
  final int? screenHeight;
  final String? platform;
  final String? language;
  final String? timezone;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
    if (screenWidth != null) 'screenWidth': screenWidth,
    if (screenHeight != null) 'screenHeight': screenHeight,
    if (platform != null) 'platform': platform,
    if (language != null) 'language': language,
    if (timezone != null) 'timezone': timezone,
    if (appVersion != null) 'appVersion': appVersion,
  };
}

/// Feedback submission request
class FeedbackRequest {
  const FeedbackRequest({
    required this.type,
    required this.content,
    this.email,
    this.name,
    this.customFields,
    this.deviceContext,
  });

  final String type;
  final String content;
  final String? email;
  final String? name;
  final Map<String, dynamic>? customFields;
  final DeviceContext? deviceContext;

  Map<String, dynamic> toJson() => {
    'type': type,
    'content': content,
    if (email != null) 'email': email,
    if (name != null) 'name': name,
    if (customFields != null) 'customFields': customFields,
    if (deviceContext != null) 'deviceContext': deviceContext!.toJson(),
  };
}

/// Feedback submission response
class FeedbackResponse {
  const FeedbackResponse({required this.success, required this.messageId});

  final bool success;
  final String messageId;

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] as bool? ?? true,
      messageId: json['messageId'] as String,
    );
  }
}
