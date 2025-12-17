import '../../../src/core/context_collector.dart' as collector;

/// Device context for feedback/chat submission
/// Matches the API deviceContextSchema
class DeviceContext {
  const DeviceContext({
    required this.platform,
    required this.deviceType,
    required this.os,
    this.osVersion,
    required this.screenWidth,
    required this.screenHeight,
    this.windowWidth,
    this.windowHeight,
    this.pixelRatio,
    this.orientation,
    this.browser,
    this.browserVersion,
    this.userAgent,
    this.appVersion,
    this.appBuildNumber,
    required this.timezone,
    required this.language,
    this.locale,
    this.connectionType,
    this.pageUrl,
    this.pageTitle,
    this.referrer,
  });

  final String platform; // 'web', 'ios', 'android'
  final String deviceType; // 'desktop', 'tablet', 'mobile'
  final String os;
  final String? osVersion;
  final int screenWidth;
  final int screenHeight;
  final int? windowWidth;
  final int? windowHeight;
  final double? pixelRatio;
  final String? orientation;
  final String? browser;
  final String? browserVersion;
  final String? userAgent;
  final String? appVersion;
  final String? appBuildNumber;
  final String timezone;
  final String language;
  final String? locale;
  final String? connectionType;
  final String? pageUrl;
  final String? pageTitle;
  final String? referrer;

  /// Create from the ContextCollector
  factory DeviceContext.collect() {
    final ctx = collector.ContextCollector.collect();
    return DeviceContext(
      platform: ctx.platform,
      deviceType: ctx.deviceType,
      os: ctx.os,
      osVersion: ctx.osVersion,
      screenWidth: ctx.screenWidth,
      screenHeight: ctx.screenHeight,
      pixelRatio: ctx.pixelRatio,
      orientation: ctx.orientation,
      timezone: ctx.timezone,
      language: ctx.language,
      locale: ctx.locale,
      connectionType: ctx.connectionType,
    );
  }

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'deviceType': deviceType,
        'os': os,
        if (osVersion != null) 'osVersion': osVersion,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        if (windowWidth != null) 'windowWidth': windowWidth,
        if (windowHeight != null) 'windowHeight': windowHeight,
        if (pixelRatio != null) 'pixelRatio': pixelRatio,
        if (orientation != null) 'orientation': orientation,
        if (browser != null) 'browser': browser,
        if (browserVersion != null) 'browserVersion': browserVersion,
        if (userAgent != null) 'userAgent': userAgent,
        if (appVersion != null) 'appVersion': appVersion,
        if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
        'timezone': timezone,
        'language': language,
        if (locale != null) 'locale': locale,
        if (connectionType != null) 'connectionType': connectionType,
        if (pageUrl != null) 'pageUrl': pageUrl,
        if (pageTitle != null) 'pageTitle': pageTitle,
        if (referrer != null) 'referrer': referrer,
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
        if (email != null && email!.trim().isNotEmpty) 'email': email,
        if (name != null && name!.trim().isNotEmpty) 'name': name,
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
